/*
 * This file was generated by qdbusxml2cpp version 0.7
 * Command line was: qdbusxml2cpp -c OcFeedsAdaptor -a ocfeedsadaptor.h:ocfeedsadaptor.cpp de.buschmann23.ocNewsEngine.Feeds.xml
 *
 * qdbusxml2cpp is Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
 *
 * This is an auto-generated file.
 * Do not edit! All changes made to it will be lost.
 */

#include "ocfeedsadaptor.h"
#include <QtCore/QMetaObject>
#include <QtCore/QByteArray>
#include <QtCore/QList>
#include <QtCore/QMap>
#include <QtCore/QString>
#include <QtCore/QStringList>
#include <QtCore/QVariant>

/*
 * Implementation of adaptor class OcFeedsAdaptor
 */

OcFeedsAdaptor::OcFeedsAdaptor(QObject *parent)
    : QDBusAbstractAdaptor(parent)
{
    // constructor
    setAutoRelaySignals(true);
}

OcFeedsAdaptor::~OcFeedsAdaptor()
{
    // destructor
}

void OcFeedsAdaptor::createFeed(const QString &url, const QString &folderId, bool eventView)
{
    // handle method call de.buschmann23.ocNewsEngine.Feeds.createFeed
    QMetaObject::invokeMethod(parent(), "createFeed", Q_ARG(QString, url), Q_ARG(QString, folderId), Q_ARG(bool, eventView));
}

void OcFeedsAdaptor::deleteFeed(const QString &id)
{
    // handle method call de.buschmann23.ocNewsEngine.Feeds.deleteFeed
    QMetaObject::invokeMethod(parent(), "deleteFeed", Q_ARG(QString, id));
}

QVariantMap OcFeedsAdaptor::getFeeds()
{
    // handle method call de.buschmann23.ocNewsEngine.Feeds.getFeeds
    QVariantMap feeds;
    QMetaObject::invokeMethod(parent(), "getFeeds", Q_RETURN_ARG(QVariantMap, feeds));
    return feeds;
}

void OcFeedsAdaptor::markFeedRead(const QString &feedId)
{
    // handle method call de.buschmann23.ocNewsEngine.Feeds.markFeedRead
    QMetaObject::invokeMethod(parent(), "markFeedRead", Q_ARG(QString, feedId));
}

void OcFeedsAdaptor::moveFeed(const QString &id, const QString &folderId)
{
    // handle method call de.buschmann23.ocNewsEngine.Feeds.moveFeed
    QMetaObject::invokeMethod(parent(), "moveFeed", Q_ARG(QString, id), Q_ARG(QString, folderId));
}

void OcFeedsAdaptor::requestFeeds()
{
    // handle method call de.buschmann23.ocNewsEngine.Feeds.requestFeeds
    QMetaObject::invokeMethod(parent(), "requestFeeds");
}

void OcFeedsAdaptor::renameFeed(const QString &id, const QString &newName)
{
    // handle method call de.buschmann23.ocNewsEngine.Feeds.renameFeed
    QMetaObject::invokeMethod(parent(), "renameFeed", Q_ARG(QString, id), Q_ARG(QString, newName));
}

