#!/usr/bin/env Rscript

#' report calculate result
#' @export
#' @param workshop_dir Directory of workshop
#' @param csv_file The file which will contain the output result (CSV format)
report_threshold <- function(workshop_dir, csv_file) {
    db_object <- connect_database(workshop_dir)
    sql_string_bare <- "SELECT * FROM `threshold`;"
    sql_string <- sprintf(sql_string_bare)

    result_obj <- dbSendQuery(db_object, sql_string)
    result_data <- dbFetch(result_obj)
    dbClearResult(result_obj)
    dbDisconnect(db_object)

    write.table(result_data, file=csv_file, sep=',', row.names=FALSE)

    return(NULL)
}
