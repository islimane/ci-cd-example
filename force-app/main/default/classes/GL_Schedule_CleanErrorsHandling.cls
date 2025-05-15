global class GL_Schedule_CleanErrorsHandling implements Schedulable{
    global void execute(SchedulableContext sc){
        GL_BATCH_CleanErrorsHandling b = new GL_BATCH_CleanErrorsHandling(); 
        database.executeBatch(b);
    }
}