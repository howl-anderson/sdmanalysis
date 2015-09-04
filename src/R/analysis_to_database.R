#!/usr/bin/env Rscript

#' analysis to Database
#'
#' @param workshop_dir dir of workshop
#' @return NULL
#' @details This function will analysis the prediction of distribution, give many optimal threshold into database
#'
#' @export
analysisToDatabase <- function(workshop_dir) {
    options('warning.length'=8170)

    # TODO: using dplyr to make all thing faster, especily split operate

    configure <- load_configure_file(workshop_dir)

    make_progress_database(workshop_dir, configure)

    db_result <- query_progress_from_database(workshop_dir)

    parameter_data <- db_result

    parameter_list <- split(parameter_data, rownames(parameter_data))

    # setup some default parallel setting
    # default number of CPU cores, all CPU cores - 1
    kDefaultCoreNumber <- detectCores() - 1
    parallel_core_number <- getOption("mc.cores", kDefaultCoreNumber)
    print(paste("Using ", parallel_core_number, " cores", sep=""))

    result <- mclapply(X=parameter_list,
                       FUN=signal_instance,
                       mc.cores=parallel_core_number,
                       workshop_dir=workshop_dir,
                       configure=configure)

    result <- unlist(result)
    if (! is.null(result)) {
        for (index in length(result)) {
            error_obj <- result[[index]]
            message <- str(error_obj)
            print(message)
        }
    }

    return(NULL)
}
