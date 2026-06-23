#include "TcpClient.h"


TcpClient::TcpClient(QObject * parent)
    : QObject(parent),
    socket(new QTcpSocket(this))
{
    connect(socket, &QTcpSocket::readyRead, this, &TcpClient::onReadyRead);
    connect(socket, &QTcpSocket::connected, this, &TcpClient::onConnected);
    connect(socket, &QTcpSocket::errorOccurred, this, &TcpClient::onError);

}

void TcpClient::connectToHost(const QString &host, int port)
{
    socket -> connectToHost(host,port);
}

void TcpClient::sendMessage(const QString &msg)
{
    if (socket->state() == QAbstractSocket::ConnectedState){
        socket->write(msg.toUtf8());
    }
}

void TcpClient::onReadyRead()
{
    QString msg = QString::fromUtf8(socket->readAll());
    emit messageRecieved(msg);
}

void TcpClient::onConnected()
{
    emit connected();
}

void TcpClient::onError(QAbstractSocket::SocketError)
{
    emit errorOccurred(socket->errorString());
}