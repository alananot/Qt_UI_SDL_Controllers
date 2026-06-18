#pragma
#include <QObject>
#include <SDL2/SDL.h>
#include <QThread>

class SdlHelper: public QObject{
    Q_OBJECT

public:
    explicit SdlHelper(QObject * parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE bool initGamepad(){
        if(SDL_Init(SDL_INIT_GAMECONTROLLER) !=0)
        {
            return false;
        }

        if(SDL_NumJoysticks() < 1)
        {
            return false;
        }

        controller = SDL_GameControllerOpen(0);
        if(!controller){
            return false;
        }
        startEventLoop();
        return true;
    }
    Q_INVOKABLE QString getError() {
        return QString(SDL_GetError());
    }

signals:
    void buttonPressed(int button);
    void axisMoved(int axis, int value);

private:
    SDL_GameController *controller = nullptr;


    void startEventLoop(){
        QThread* thread = QThread::create([this](){
            SDL_Event e;
            SDL_GameControllerEventState(SDL_ENABLE);
            SDL_JoystickEventState(SDL_ENABLE);
            while(true){
                SDL_PumpEvents();
                while(SDL_PollEvent(&e)){
                    switch (e.type){
                    case SDL_CONTROLLERDEVICEADDED:
                        if(!controller){
                            controller = SDL_GameControllerOpen(e.cdevice.which);
                        }
                        break;

                    case SDL_CONTROLLERBUTTONDOWN:
                        emit buttonPressed(e.cbutton.button);
                            break;
                    case SDL_CONTROLLERAXISMOTION:
                        emit axisMoved(e.caxis.axis, e.caxis.value);
                        break;
                    }
                }
                SDL_Delay(1);
            }
        });
        thread->start();
    }
};


