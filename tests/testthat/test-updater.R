
library(testthat)
library(updateRpkg)

test_that("version checking works", {
    version_info <- checkUpdaterVersion()
    expect_type(version_info, "list")
    expect_true("local_version" %in% names(version_info))
    expect_true("remote_version" %in% names(version_info))
    expect_true("needs_update" %in% names(version_info))
})

test_that("package locking works", {
    lockPackageVersions("base")
    expect_true(file.exists("package.lock"))
    lock_check <- checkLockFile()
    expect_type(lock_check, "list")
})
