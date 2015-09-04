#!/usr/bin/env Rscript

#' Signal CPU instance
#' @param parameter run parameter
#' @param workshop_dir Directory of workshop
#' @param configure Configure object
signal_instance <- function(parameter, workshop_dir, configure) {
    parameter_list <- as.list(parameter)

    runtime <- parameter_list[["runtime"]]
    species_name <- parameter_list[["species"]]
    algorithm <- parameter_list[["algorithm"]]
    task_flag <- parameter_list[["mark"]]

    if (task_flag) {
        # task have been marked as finished, so just return NULL
        return(NULL)
    }

    # connect to database
    db_object <- connect_database(workshop_dir)

    run_env <- new.env()
    run_env$species <- species_name
    run_env$algorithm <- algorithm
    run_env$runtime <- runtime

    predict_environment_set_list <- configure[["predict"]]

    presence_file <- file.path(workshop_dir, "species", species_name, "presence.bil")
    presence_raster <- raster(presence_file)
    presence_point <- rasterToPoints(presence_raster)[, 1:2]
    presence_variable <- rasterToPoints(presence_raster)[, 3]

    absence_file <- file.path(workshop_dir, "species", species_name, "absence.bil")
    absence_raster <- raster(absence_file)
    absence_point <- rasterToPoints(absence_raster)[, 1:2]
    absence_variable <- rasterToPoints(absence_raster)[, 3]

    observed_point <- rbind(presence_point, absence_point)
    observed_value <- c(rep(1, length(presence_variable)),
                        rep(0, length(absence_variable)))

    predicted_suitability_file <- file.path(workshop_dir,
                                            "result",
                                            species_name,
                                            "base",
                                            algorithm,
                                            runtime,
                                            "suitability",
                                            "map.bil")

    predicted_suitability_raster <- raster(predicted_suitability_file)

    predicted_variable <- extract(predicted_suitability_raster, observed_point)

    # TODO: this maybe a tiny issue
    # if predicted variable have NA, we will remove this location from predicted and observed
    if (any(is.na(predicted_variable))) {
        message <- paste("File <",
                         paste("result",
                               species_name,
                               "base",
                               algorithm,
                               runtime,
                               "suitability",
                               "map.bil",
                               sep="/"),
                         "> have at least a different cell which is missing (NA). ",
                         sep="")

        na_count <- length(predicted_variable[is.na(predicted_variable)])
        total_number <- length(predicted_variable)

        message <- paste(message, paste0(as.character(na_count), ' ', as.character(na_count/total_number*100)), '', sep="\n")

        cat(message)

        not_na_index <- which(!is.na(predicted_variable))
        observed_value <- observed_value[not_na_index]
        predicted_variable <- predicted_variable[not_na_index]
    }

    optimal_threshold <- optimalThreshold(observed_value, predicted_variable)

    threshold_method_name_list <- names(optimal_threshold)

    if ("analysis_progress" %in% dbListTables(db_object)) {
        # save data into database
        sql_string <- paste("SELECT * FROM analysis_progress WHERE species='",
                            species_name, "' AND algorithm='",
                            algorithm, "' AND runtime='",
                            runtime, "'", sep="")
        print(sql_string)
        query_result <- dbSendQuery(db_object, sql_string)
        if (dbGetRowCount(query_result) > 0) {
            db_item_exist_flag <- TRUE
        } else {
            db_item_exist_flag <- FALSE
        }
        dbClearResult(query_result)
    } else {
        db_item_exist_flag <- FALSE
    }

    if (db_item_exist_flag) {
        sql_string <- paste("DELETE FROM analysis_progress WHERE species='",
                            species_name, "' AND algorithm='",
                            algorithm, "' AND runtime='",
                            runtime, "'", sep="")
        dbSendQuery(db_object, sql_string)
    }

    for (threshold_method_name in threshold_method_name_list) {
        threshold <- optimal_threshold[[threshold_method_name]]

        precision_list <- evaluatePrecision(observed_value, predicted_variable, threshold)

        result_data <- precision_list
        result_data[["species"]] <- species_name
        result_data[["algorithm"]] <- algorithm
        result_data[["threshold_method"]] <- threshold_method_name
        result_data[["threshold_value"]] <- threshold
        result_data[["runtime"]] <- runtime

        # turn list into data.frame
        result_data <- as.data.frame(result_data, row.names=NULL)

        # write to database
        dbWriteTable(db_object, "analysis_result", result_data, append=TRUE, row.names=FALSE)
    }

    sql_string <- paste("UPDATE analysis_progress SET mark=1 WHERE species='",
                        species_name, "' AND algorithm='",
                        algorithm, "' AND runtime='",
                        runtime, "'", sep="")

    print(sql_string)
    dbSendQuery(db_object, sql_string)

    # Close database connection
    dbDisconnect(db_object)

    return(NULL)
}
