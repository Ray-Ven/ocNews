#include "ocfeedsmodelfilter.h"
#include "QsLog.h"

OcFeedsModelFilter::OcFeedsModelFilter(QObject *parent) :
    QSortFilterProxyModel(parent)
{
    m_orderBy = "id";
    m_hideRead = false;
    this->setDynamicSortFilter(true);
    this->setSortCaseSensitivity(Qt::CaseInsensitive);
    this->setSortLocaleAware(true);
    this->setSorting();
}



QString OcFeedsModelFilter::orderBy() const { return m_orderBy; }

void OcFeedsModelFilter::setOrderBy(const QString &nOrderBy)
{
    if (nOrderBy != m_orderBy) {
        m_orderBy = nOrderBy;
        QLOG_DEBUG() << "Feeds model filter: changed sort order to " << orderBy();
        setSorting();
        emit orderByChanged(orderBy());
    }
}


bool OcFeedsModelFilter::hideRead() const { return m_hideRead; }

void OcFeedsModelFilter::setHideRead(const bool &nHideRead)
{
    if (nHideRead != m_hideRead) {
        m_hideRead = nHideRead;
        QLOG_DEBUG() << "Feeds model filter: changed hide read to " << hideRead();
        this->invalidateFilter();
        this->invalidate();
        emit hideReadChanged(hideRead());
    }
}



bool OcFeedsModelFilter::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    QModelIndex index = sourceModel()->index(source_row, 0, source_parent);

    if (hideRead()) {
        return (sourceModel()->data(index, OcFeedsModelNew::UnreadCountRole).toInt() > 0);
    } else {
        return true;
    }
}



bool OcFeedsModelFilter::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    QPair<int, Qt::SortOrder> roleOrder;
    int role, c;
    QVariant l, r;
    QModelIndex idxLeft, idxRight;

    foreach(roleOrder, m_orders)
    {
        role = roleOrder.first;
        idxLeft = left.model()->index(left.row(), 0, left.parent());
        idxRight = right.model()->index(right.row(), 0, right.parent());

        if (roleOrder.second == Qt::AscendingOrder) {
            l = idxLeft.data(role);
            r = idxRight.data(role);
        } else {
            r = idxLeft.data(role);
            l = idxRight.data(role);
        }

        switch (l.userType())
        {
        case QVariant::Invalid:
            return(r.type() == QVariant::Invalid);
        case QVariant::Int:
            if (l.toInt() < r.toInt())
                return true;
            else if (l.toInt() > r.toInt())
                return false;
            break;
        default:
            if (isSortLocaleAware())
            {
                c = l.toString().localeAwareCompare(r.toString());
                if (c<0)
                    return true;
                else if (c>0)
                    return false;
            } else {
                c = l.toString().compare(r.toString(), sortCaseSensitivity());
                if (c<0)
                    return true;
                else if (c>0)
                    return false;
            }
        }
    }

    return true;
}


void OcFeedsModelFilter::setSorting()
{
    if (orderBy() == "id") {
        m_orders.clear();
        m_orders.append(qMakePair(OcFeedsModelNew::TypeRole, Qt::DescendingOrder));
        m_orders.append(qMakePair(OcFeedsModelNew::IdRole, Qt::DescendingOrder));
    } else if (orderBy() == "title") {
        m_orders.clear();
        m_orders.append(qMakePair(OcFeedsModelNew::TypeRole, Qt::DescendingOrder));
        m_orders.append(qMakePair(OcFeedsModelNew::TitleRole, Qt::AscendingOrder));
    } else {
        m_orders.clear();
        m_orders.append(qMakePair(OcFeedsModelNew::TypeRole, Qt::DescendingOrder));
        m_orders.append(qMakePair(OcFeedsModelNew::UnreadCountRole, Qt::DescendingOrder));
    }

    this->sort(0);
    this->invalidate();
    this->invalidateFilter();
}
