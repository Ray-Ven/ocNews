/*
 * This file was generated by qdbusxml2cpp version 0.7
 * Command line was: qdbusxml2cpp -c OcGenericAdaptor -a ocgenericadaptor.h:ocgenericadaptor.cpp de.buschmann23.ocNewsEngine.Generic.xml
 *
 * qdbusxml2cpp is Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
 *
 * This is an auto-generated file.
 * Do not edit! All changes made to it will be lost.
 */

#include "ocgenericadaptor.h"
#include <QtCore/QMetaObject>
#include <QtCore/QByteArray>
#include <QtCore/QList>
#include <QtCore/QMap>
#include <QtCore/QString>
#include <QtCore/QStringList>
#include <QtCore/QVariant>

/*
 * Implementation of adaptor class OcGenericAdaptor
 */

OcGenericAdaptor::OcGenericAdaptor(QObject *parent)
    : QDBusAbstractAdaptor(parent)
{
    // constructor
    setAutoRelaySignals(true);
}

OcGenericAdaptor::~OcGenericAdaptor()
{
    // destructor
}

void OcGenericAdaptor::getVersion()
{
    // handle method call de.buschmann23.ocNewsEngine.Generic.getVersion
    QMetaObject::invokeMethod(parent(), "getVersion");
}

void OcGenericAdaptor::initConnection()
{
    // handle method call de.buschmann23.ocNewsEngine.Generic.initConnection
    QMetaObject::invokeMethod(parent(), "initConnection");
}

void OcGenericAdaptor::quitEngine()
{
    // handle method call de.buschmann23.ocNewsEngine.Generic.quitEngine
    QMetaObject::invokeMethod(parent(), "quitEngine");
}