#!/usr/bin/env Rscript

#' create_database_table
#' @param workshop_dir Directory of workshop
#' @export
#' @return Boolean
create_database_table <- function(workshop_dir) {
    sql_file <- file.path(system.file(package='sdmanalysis'), '/sql/table.sql')
    import_sql(workshop_dir, sql_file)
}
