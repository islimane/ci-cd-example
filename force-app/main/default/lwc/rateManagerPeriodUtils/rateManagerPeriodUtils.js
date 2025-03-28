/**
 * @description       :
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 26-03-2025
 * @last modified by  : alberto.martinez-lopez@inetum.com
**/

import RateManagerPeriodInterval from './rateManagerPeriodInterval';
import LABELS from './labels';


class RateManagerPeriodUtils {

    labels = LABELS;

    constructor(dateIntervals, season) {
        this._dateIntervals = [];
        this._season = season;
        dateIntervals.forEach( interval => {
            this._dateIntervals.push(new RateManagerPeriodInterval(interval));
        });
    }

    hasAvailableSlots() {
        return this.findFirstAvailableInterval() != null;
    }

    findFirstAvailableIntervalDays(days) {
        let firstInterval = this.findFirstAvailableInterval();
        if (!firstInterval) return null;

        let maxEndDateAvailable = new Date(firstInterval.EndDate__c);
        let suggestedEndDate = new Date(firstInterval.StartDate__c);
        suggestedEndDate.setDate(suggestedEndDate.getDate() + days);
        if (suggestedEndDate > maxEndDateAvailable) firstInterval.EndDate__c = maxEndDateAvailable;
        else firstInterval.EndDate__c = suggestedEndDate;
        return firstInterval.getISOFormattedDates();
    }

    findFirstAvailableInterval() {
        // Get the current year and define its start and end dates
        const startOfSeason = new Date(this._season.StartDate__c);
        const endOfSeason = new Date(this._season.EndDate__c);

        // If there are no existing intervals, return the full year
        if (!this._dateIntervals || this._dateIntervals.length === 0) {
            return new RateManagerPeriodInterval({
                StartDate__c: startOfSeason,
                EndDate__c: endOfSeason
            }).getISOFormattedDates();
        }

        // Sort intervals by start date
        const sortedIntervals = [...this._dateIntervals].sort((a, b) => a.StartDate__c - b.StartDate__c);

        // Filter intervals that overlap with the current year
        const relevantIntervals = sortedIntervals.filter(interval =>
            interval.overlapsWith(new RateManagerPeriodInterval({
                StartDate__c: startOfSeason,
                EndDate__c: endOfSeason
            }))
        );

        // If no relevant intervals exist, return the full year
        if (relevantIntervals.length === 0) {
            return new RateManagerPeriodInterval({
                StartDate__c: startOfSeason,
                EndDate__c: endOfSeason
            }).getISOFormattedDates();
        }

        // Check for a gap at the beginning of the year
        if (relevantIntervals[0].StartDate__c > startOfSeason) {
            const endDate = new Date(relevantIntervals[0].StartDate__c.getTime() - 86400000);
            if (endDate >= startOfSeason) {
                return new RateManagerPeriodInterval({
                    StartDate__c: startOfSeason,
                    EndDate__c: endDate
                }).getISOFormattedDates();
            }
        }

        // Look for gaps between intervals
        for (let i = 0; i < relevantIntervals.length - 1; i++) {
            const currentEnd = relevantIntervals[i].EndDate__c;
            const nextStart = relevantIntervals[i + 1].StartDate__c;

            if (nextStart - currentEnd > 86400000) { // More than one day gap
                return new RateManagerPeriodInterval({
                    StartDate__c: new Date(currentEnd.getTime() + 86400000),
                    EndDate__c: new Date(nextStart.getTime() - 86400000)
                }).getISOFormattedDates();
            }
        }

        // Check for a gap at the end of the year
        const lastInterval = relevantIntervals[relevantIntervals.length - 1];
        if (lastInterval.EndDate__c < endOfSeason) {
            return new RateManagerPeriodInterval({
                StartDate__c: new Date(lastInterval.EndDate__c.getTime() + 86400000),
                EndDate__c: endOfSeason
            }).getISOFormattedDates();
        }

        // No available gaps found in the current year
        return null;
    }

    checkSlots(formData) {
        const newInterval = new RateManagerPeriodInterval(formData);
        for (const interval of this._dateIntervals) {
            if (newInterval.overlapsWith(interval)) {
                throw new Error(this.labels.overlap_error);
            }
        }
    }
}

export default RateManagerPeriodUtils
