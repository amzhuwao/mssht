pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "MSSHT"
include(
    ":app",
    ":core:common",
    ":core:model",
    ":core:designsystem",
    ":core:network",
    ":core:database",
    ":core:datastore",
    ":feature:auth",
    ":feature:home",
    ":feature:notifications",
    ":feature:sync",
)
