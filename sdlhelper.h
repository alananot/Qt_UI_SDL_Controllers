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
    void buttonReleased(int button);
    void buttonPressed(int button);
    void axisMoved(int axis, int value);

private:
    SDL_GameController *controller = nullptr;

    void startEventLoop(){
        QThread* thread = QThread::create([this](){

            SDL_Event e;
            SDL_GameControllerEventState(SDL_ENABLE);
            SDL_JoystickEventState(SDL_ENABLE);

            bool lastState[SDL_CONTROLLER_BUTTON_MAX] = {false};

            while (true) {

                // Läs SDL-events
                SDL_PumpEvents();
                while (SDL_PollEvent(&e)) {
                    switch (e.type) {

                    case SDL_CONTROLLERAXISMOTION:
                        emit axisMoved(e.caxis.axis, e.caxis.value);
                        break;

                        // OBS: Vi ignorerar BUTTONDOWN/UP här
                        // eftersom vi gör egen state-tracking
                    }
                }

                // Egen knapp-state tracking
                for (int b = 0; b < SDL_CONTROLLER_BUTTON_MAX; b++) {

                    bool current = SDL_GameControllerGetButton(
                        controller,
                        (SDL_GameControllerButton)b
                        );

                    if (current && !lastState[b]) {
                        emit buttonPressed(b);
                    }
                    if (!current && lastState[b]) {
                        emit buttonReleased(b);
                    }

                    lastState[b] = current;
                }

                SDL_Delay(10);
            }
        });

        thread->start();
    }

};


