#!/usr/bin/env Rscript

#' query_progress_from_database
#' @param workshop_dir Directory of workshop
#' @export
query_progress_from_database <- function(workshop_dir) {
    db_object <- connect_database(workshop_dir)

    sql_string <- "SELECT * FROM analysis_progress"

    query_result <- dbSendQuery(db_object, sql_string)
    db_result <- dbFetch(query_result, n=-1)
    dbClearResult(query_result)
    dbDisconnect(db_object)

    return(db_result)
}
