# CronJobs 

they have five asterics in a cron job 

+    *   | *  | *  |  *  |  *
  

what  they represent here  
mins | hrs | day of the month | month | day of the week 

to run a jobs at every minute we use */n , like when we want to run every 10mins we use */n

how to get logs for jobs 

+ `kubectl logs -n vault -l job-name=vault-job-name-here`
+ kubectl logs -n vault -l job-name=vault-unseal-29450275
