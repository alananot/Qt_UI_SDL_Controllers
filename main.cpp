#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <SDL2/SDL.h>

#include "sdlhelper.h"
int main(int argc, char *argv[])
{



    QGuiApplication app(argc, argv);
    qmlRegisterType<SdlHelper>("SDL", 1, 0, "SdlHelper");

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("test4", "Main");

    return QGuiApplication::exec();
}
