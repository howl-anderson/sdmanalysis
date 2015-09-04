#!/usr/bin/env Rscript

#' load_database_to_data_frame
#'
#' @param workshop_dir dir of workshop
#' @return data.frame of result
#'
#' @export
load_database_to_data_frame <- function(workshop_dir) {
    db.object <- connect_database(workshop_dir)

    sql.string <- "select * from meta"

    data <- dbGetQuery(db.object, sql.string)

    return(data)
}
