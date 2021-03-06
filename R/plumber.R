# plumber.R

#* Download a package from URL
#* @param u The URL for a repo
#* @post /report
function (u) {

    pkg_name <- tail (strsplit (u, "/") [[1]], 1)
    org <- tail (strsplit (u, "/") [[1]], 2) [1]

    cache_dir <- Sys.getenv ("cache_dir")
    repo_updated <- pkgreport::check_cache (org, pkg_name, cache_dir)
    branch <- pkgreport::get_default_branch (org, pkg_name)

    download_repo <- function (u, pkg_name, branch) {

        if (substring (u, nchar (u), nchar (u)) == "/")
            u <- substring (u, 1, nchar (u) - 1)
        u <- paste0 (u, "/archive/", branch, ".zip")

        f <- file.path (cache_dir, paste0 (pkg_name, "-", branch, ".zip"))
        download.file (u, destfile = f)
        return (f)
    }

    local_repo <- file.path (cache_dir, paste0 (pkg_name, "-", branch, ""))
    local_zip <- paste0 (local_repo, ".zip")

    if (!file.exists (local_zip) | repo_updated) {

        message ("downloading repo ...")
        f <- download_repo (u, pkg_name, branch)
    }

    flist <- unzip (local_zip, exdir = cache_dir)
    g <- packgraph::pg_graph (local_repo, plot = FALSE)
    res <- packgraph::pg_report (g, exported_only = FALSE)

    message ("unlinking ", local_repo)
    chk <- unlink (local_repo, recursive = TRUE)

    return (res)
}

#* @get /mean
getmean <- function (n = 10) {

    return (mean (rnorm (n)))
}
