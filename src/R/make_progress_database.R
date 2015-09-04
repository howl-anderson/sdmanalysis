#!/usr/bin/env Rscript

#' make_progress_database
#' @param workshop_dir Directory of workshop
#' @param configure Configure object
make_progress_database <- function(workshop_dir, configure) {
    species_name_vector <- configure[["species_name"]]
    algorithms_list <- configure[["algorithms"]]
    runtimes_number <- configure[["run_times"]]
    predict_environment_set <- configure[["predict"]]

    # TODO: need try-catch here
    db_object <- connect_database(workshop_dir)

    if ("analysis_progress" %in% dbListTables(db_object)) {
        # TODO: more
        sql_string <- "SELECT COUNT(*) FROM analysis_progress"
        result_obj <- dbSendQuery(db_object, sql_string)
        result_data <- dbFetch(result_obj)
        dbClearResult(result_obj)
        row_count <- result_data[1, 1]

        if (row_count > 0) {
            print("Found progress database, create process have been passed")

            return(FALSE)
        } else {
            print("Start to create analysis_progress database")

            data_grid <- expand.grid(species_name=species_name_vector,
                                     algorithms=algorithms_list,
                                     runtime=seq(runtimes_number),
                                     mark=0,
                                     elapsed_senconds=-1)

            data_grid <- as.data.frame(data_grid)

            data_list <- split(data_grid, rownames(data_grid))

            db_object <- connect_database(workshop_dir)

            lapply(X=data_list, FUN=function(x) {
                        item <- as.list(x)

                        sql_string_bare <- "INSERT INTO `analysis_progress` (`id`, `species`, `algorithm`, `environment`, `runtime`, `mark`, `elapsed_time`) VALUES (NULL, '%s', '%s', NULL, '%s', '%s', '%s');"

                        sql_string <- sprintf(sql_string_bare,
                                              item$species_name,
                                              item$algorithms,
                                              item$runtime,
                                              item$mark,
                                              item$elapsed_senconds)

                        dbSendQuery(db_object, sql_string)
                   })
            dbDisconnect(db_object)

            print("Creating analysis_progress database is done!")

            return(TRUE)
        }
    } else {
        # pass
    }
}
