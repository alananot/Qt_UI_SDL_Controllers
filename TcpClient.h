#ifndef TCPCLIENT_H
#define TCPCLIENT_H
#include <QObject>
#include <QTcpSocket>


class TcpClient : public QObject{
    Q_OBJECT

public:
    explicit TcpClient(QObject * parent = nullptr);
    Q_INVOKABLE void connectToHost(const QString &host, int port);
    Q_INVOKABLE void sendMessage(const QString &msg);

signals:
    void messageRecieved(QString msg);
    void connected();
    void errorOccurred(QString err);
private slots:
    void onReadyRead();
    void onConnected();
    void onError(QAbstractSocket::SocketError socketError);

private:
    QTcpSocket * socket;


};


#endif // TCPCLIENT_H
