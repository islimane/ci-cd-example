class RateManagerPeriodInterval {
    constructor(data) {
        Object.assign(this, data);
        this.StartDate__c = new Date(data.StartDate__c);
        this.EndDate__c = new Date(data.EndDate__c);
        
        if (this.StartDate__c > this.EndDate__c) {
            throw new Error("Start date must be before end date");
        }
    }

    getISOFormattedDates(){
        this.StartDate__c = new Date(this.StartDate__c).toISOString().split("T")[0];
        this.EndDate__c = new Date(this.EndDate__c).toISOString().split("T")[0];
        return this;
    }

    overlapsWith(otherInterval) {
        return this.StartDate__c < otherInterval.EndDate__c && this.EndDate__c > otherInterval.StartDate__c;
    }

    contains(date) {
        const checkDate = new Date(date);
        return checkDate >= this.StartDate__c && checkDate <= this.EndDate__c;
    }

    durationInDays() {
        const msPerDay = 1000 * 60 * 60 * 24;
        return Math.round((this.EndDate__c - this.StartDate__c) / msPerDay);
    }
}

export default RateManagerPeriodInterval;
