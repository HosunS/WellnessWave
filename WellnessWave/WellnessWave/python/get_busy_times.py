import firebase_admin
from firebase_admin import credentials, db
import time
from datetime import datetime, timedelta

cred = credentials.Certificate("credentials.json")
firebase_admin.initialize_app(cred , {"databaseURL": "https://wellnesswave-903af-default-rtdb.firebaseio.com/"})


#Busy times: [start_time, end_time, minutes_available]
# busy_times = [["08:00", "10:00"], ["12:00", "14:00"], ["16:00", "18:00"]]
busy_times = []
free_times = []
desired_duration = 120

users = db.reference("/users").get()
for id, val in users.items():
    try:
        events = db.reference(f'/users/{id}/events').get()
        for event in events.values():
            
            #extracts time from event in the following format: 'HH:MM' and append to busy_times
            busy_times.append([event['startDate'][11:16], event['endDate'][11:16]])
            
    #User has no events, treated as free all day
    except:
        pass

#algo for finding free_times in users day

#Check if any busy times exist, if not, all day is free.
if busy_times != []:
    
    #check if first busy_time includes openning time for arc
    if busy_times[0][0] != "06:00":
        start_time = datetime.strptime("06:00", "%H:%M")
        end_time = datetime.strptime(busy_times[0][0], "%H:%M")
        free_times.append(["06:00", busy_times[0][0], (end_time-start_time).total_seconds() / 60]) 
    
    #cases where times dont include openning or close time
    for i in range(len(busy_times) - 1):
        if busy_times[i][1] < busy_times[i+1][0]:
            start_time = datetime.strptime(busy_times[i][1], "%H:%M")
            end_time = datetime.strptime(busy_times[i+1][0], "%H:%M")
            free_times.append([busy_times[i][1], busy_times[i+1][0], (end_time-start_time).total_seconds() / 60])
    
    #check if last busy_time includes one hour before closing time for arc
    if busy_times[-1][1] != "23:00":
        start_time = datetime.strptime(busy_times[-1][1], "%H:%M")
        end_time = datetime.strptime("22:00", "%H:%M")
        free_times.append([busy_times[-1][1], "23:00", (end_time-start_time).total_seconds() / 60])
else:
    #All day is free
    free_times.append(["06:00", "23:00", 960.0])

print(busy_times)
print(free_times)