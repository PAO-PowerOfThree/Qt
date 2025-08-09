cmake_minimum_required(VERSION 3.16)

project(PaoCluster VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Core SerialBus)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appPaoCluster
    main.cpp
    systemmanager.h
    systemmanager.cpp
    busreader.cpp
    busreader.h
)
qt_add_qml_module(appPaoCluster
    URI PaoCluster
    VERSION 1.0
    QML_FILES
        qml/Main.qml
   SOURCES busreader.h
           busreader.cpp
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
            Qt6::Core
            Qt6::SerialBus
)

include(GNUInstallDirs)
install(TARGETS appPaoCluster
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
