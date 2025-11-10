extra.apply {
    set("projectMVersion", project.findProperty("PROJECTM_VERSION") ?: "LOCAL-SNAPSHOT")
}
