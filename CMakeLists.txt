cmake_minimum_required(VERSION 3.16)

project(PaoCluster VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appPaoCluster
    main.cpp
)

# Load QML & image from .qrc
qt6_add_resources(APP_RESOURCES resources.qrc)
target_sources(appPaoCluster PRIVATE ${APP_RESOURCES})

set_target_properties(appPaoCluster PROPERTIES
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
)

target_link_libraries(appPaoCluster
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appPaoCluster
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
