#!/usr/bin/env Rscript
# TODO: more check need be

query_species_data <- function(species_name, workshop_dir, algorithm, threshold_method) {
    db_object <- connect_database(workshop_dir)

    sql_string_bare <- "SELECT *
                        FROM  `analysis_result`
                        WHERE  `species`='%s'
                        AND  `algorithm`='%s'
                        AND  `threshold_method`='%s';"
    sql_string <- sprintf(sql_string_bare,
                          species_name,
                          algorithm,
                          threshold_method)

    result_obj <- dbSendQuery(db_object, sql_string)
    result_data <- dbFetch(result_obj)
    dbClearResult(result_obj)
    dbDisconnect(db_object)

    result <- result_data

    return(result)
}

threshold_find_max <- function(species_name, workshop_dir, algorithm, threshold_method) {
    species_data <- query_species_data(species_name, workshop_dir, algorithm, threshold_method)

    max_index <- which.max(species_data[, 'threshold_value'])
    db_id <- species_data[which.max, 'id']

    return(db_id)
}

threshold_most_near_mean <- function(species_name, workshop_dir, algorithm, threshold_method) {
    species_data <- query_species_data(species_name, workshop_dir, algorithm, threshold_method)
    # TODO
    standard <- 'threshold_value'
    mean_value <- mean(species_data[, standard])
    threshold_distance <- species_data
    threshold_distance[, standard] <- abs(species_data[, standard] - mean_value)
    db_id <- threshold_distance[which.min(threshold_distance[, standard]), 'id']

    return(db_id)
}

threshold_mean <- function() {

}

threshold_find_min <- function(species_name, workshop_dir, algorithm, threshold_method) {
    species_data <- query_species_data(species_name, workshop_dir, algorithm, threshold_method)

    max_index <- which.min(species_data[, 'threshold_value'])
    db_id <- species_data[which.max, 'id']

    return(db_id)
}

standard_find_max <- function(species_name, workshop_dir, algorithm, threshold_method, standard) {
    species_data <- query_species_data(species_name, workshop_dir, algorithm, threshold_method)
    max_index <- which.max(species_data[, standard])
    db_id <- species_data[which.max, 'id']

    return(db_id)
}

standard_most_near_mean <- function(species_name, workshop_dir, algorithm, threshold_method, standard) {
    species_data <- query_species_data(species_name, workshop_dir, algorithm, threshold_method)

    mean_value <- mean(species_data[, standard])

    threshold_distance <- species_data
    abs_value <- abs(species_data[, standard] - mean_value)
    db_id <- threshold_distance[which.min(abs_value), 'id']

    return(db_id)
}

standard_mean <- function() {

}

standard_find_min <- function(species_name, workshop_dir, algorithm, threshold_method, standard) {
    species_data <- query_species_data(species_name, workshop_dir, algorithm, threshold_method)

    max_index <- which.min(species_data[, standard])
    db_id <- species_data[which.max, 'id']

    return(db_id)
}



apply_threshold_binary_distribution_instance <- function(runtime_info, workshop_dir) {
    # setup runtime argument
    runtime_info <- as.data.frame(runtime_info)
    species_name <- runtime_info$species_name
    algorithm <- runtime_info$algorithm
    threshold_method <- runtime_info$threshold_method
    select_method <- runtime_info$select_method
    standard <- runtime_info$standard

    if (select_method == 'threshold_find_max') {
        db_id <- threshold_find_max(species_name, workshop_dir, algorithm, threshold_method)
    } else if (select_method == 'threshold_most_near_mean') {
        db_id <- threshold_most_near_mean(species_name, workshop_dir, algorithm, threshold_method)
    } else if (select_method == 'threshold_find_min') {
        db_id <- threshold_find_min(species_name, workshop_dir, algorithm, threshold_method)
    } else if (select_method == 'standard_find_max') {
        db_id <- standard_find_max(species_name, workshop_dir, algorithm, threshold_method, standard)
    } else if (select_method == 'standard_most_near_mean') {
        db_id <- standard_most_near_mean(species_name, workshop_dir, algorithm, threshold_method, standard)
    } else if (select_method == 'standard_find_min') {
        db_id <- standard_find_min(species_name, workshop_dir, algorithm, threshold_method, standard)
    } else {
        # TODO: something wronge
        stop('select_method missing')
    }

    db_object <- connect_database(workshop_dir)

    sql_string_bare <- "SELECT * FROM analysis_result WHERE id='%s'"
    sql_string <- sprintf(sql_string_bare,
                          db_id)

    result_obj <- dbSendQuery(db_object, sql_string)
    result_data <- dbFetch(result_obj)
    dbClearResult(result_obj)

    threshold <- result_data[1, 'threshold_value']
    runtime <- result_data[1, 'runtime']

    suitability_file <- file.path(workshop_dir,
                                  "result",
                                  species_name,
                                  "base",
                                  algorithm,
                                  runtime,
                                  "suitability/map.bil")
    suitability_raster <- raster(suitability_file)
    binrary_map_raster <- suitability_raster >= threshold
    binrary_map_dir <- file.path(workshop_dir,
                                 "result",
                                 species_name,
                                 "base",
                                 algorithm,
                                 runtime,
                                 "distribution",
                                 threshold_method)
    if (! file.exists(binrary_map_dir)) {
        dir.create(binrary_map_dir, showWarnings=FALSE, recursive=TRUE)
    }
    binrary_map_file <- file.path(binrary_map_dir, "map.bil")
    writeRaster(x=binrary_map_raster,
                filename=binrary_map_file,
                format="EHdr",
                overwrite=TRUE)

    # binary predicted map
    configure_list <- load_configure_file(workshop_dir)
    environment_list <- configure_list$predict
    for (environment in environment_list) {
        suitability_file <- file.path(workshop_dir,
                                      "result",
                                      species_name,
                                      environment,
                                      algorithm,
                                      runtime,
                                      "suitability/map.bil")
        suitability_raster <- raster(suitability_file)
        binrary_map_raster <- suitability_raster >= threshold
        binrary_map_dir <- file.path(workshop_dir,
                                     "result",
                                     species_name,
                                     environment,
                                     algorithm,
                                     runtime,
                                     "distribution",
                                     threshold_method)
        if (! file.exists(binrary_map_dir)) {
            dir.create(binrary_map_dir, showWarnings=FALSE, recursive=TRUE)
        }
        binrary_map_file <- file.path(binrary_map_dir, "map.bil")
        writeRaster(x=binrary_map_raster,
                    filename=binrary_map_file,
                    format="EHdr",
                    overwrite=TRUE)
    }


    # write to database
    sql_string_bare <- "INSERT INTO `threshold` (`id`, `species`, `algorithm`, `threshold_method`, `standard`, `relative_id`, `runtime`, `threshold_value`) VALUES (NULL, '%s', '%s', '%s', '%s', '%s', '%s', '%s');"
    sql_string <- sprintf(sql_string_bare,
                          species_name,
                          algorithm,
                          threshold_method,
                          standard,
                          db_id,
                          runtime,
                          threshold)
    result_obj <- dbSendQuery(db_object, sql_string)
    dbClearResult(result_obj)
    dbDisconnect(db_object)

    return(NULL)
}

#' apply_threshold_binary_distribution
#'
#' @param workshop_dir Directory of workshop
#' @param algorithm Which modelling algorithm(s) resutl user want to binary distribution.
#'        Default is all that used in SDMengine modelling.
#' @param threshold_method How to choose threshold. Defalut is all that SDManalysis can provide
#' @param select_method How to choose method to choose threshold
#' @param standard The cites which will been used in select_method
#' @return NULL
#' @export
apply_threshold_binary_distribution <- function(workshop_dir,
                                                algorithm=TRUE,
                                                threshold_method=TRUE,
                                                select_method=TRUE,
                                                standard=TRUE) {
    if (is.logical(algorithm)) {
        if (algorithm) {
            db_object <- connect_database(workshop_dir)
            sql_string_bare <- "SELECT DISTINCT `algorithm`
                                FROM `analysis_result`;"
            sql_string <- sprintf(sql_string_bare)

            result_obj <- dbSendQuery(db_object, sql_string)
            result_data <- dbFetch(result_obj)
            dbClearResult(result_obj)

            algorithm_list <- result_data[, 'algorithm']

            dbDisconnect(db_object)
        } else {
            # Illegal value
            stop('FALSE is a illegal value for algorithm')
        }
    } else {
        # TODO
    }


    if (is.logical(threshold_method)) {
        if (threshold_method) {
            # Query all threshold_method used in project, and use them all
            db_object <- connect_database(workshop_dir)
            sql_string_bare <- "SELECT DISTINCT `threshold_method`
                                FROM `analysis_result`;"
            sql_string <- sprintf(sql_string_bare)

            result_obj <- dbSendQuery(db_object, sql_string)
            result_data <- dbFetch(result_obj)
            dbClearResult(result_obj)

            threshold_list <- result_data[, 'threshold_method']

            dbDisconnect(db_object)
        } else {
            # Illegall value
        }
    } else {
        # TODO
    }


    configure_list <- load_configure_file(workshop_dir)
    cpu_cores <- get_cpu_cores(workshop_dir)
    species_name <- configure_list[['species_name']]

    runtime_info <- expand.grid(species_name=species_name,
                                algorithm=algorithm,
                                threshold_method=threshold_method,
                                select_method=select_method,
                                standard=standard)
    runtime_info <- split(runtime_info, rownames(runtime_info))

    mclapply(X=runtime_info,
             FUN=apply_threshold_binary_distribution_instance,
             mc.cores=cpu_cores,
             workshop_dir)

    return(NULL)
}
