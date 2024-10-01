//Single Elevator system with queue n all

#define TOTAL_FLOOR  10 
#define TIME 20
#define NO 11

byte request[TIME+1] = {3,5,2,1,9,11,11,11,11,11,11,11,4};                 // 2 5 1 
int cur_floor = 0 , cur_dir = 0;
int max_up = 0 , min_down = TOTAL_FLOOR;
bool down = false, up = false;
bool up_stop[TOTAL_FLOOR+1] , down_stop[TOTAL_FLOOR+1];
bool isDoorOpen = false;

#define QUEUE_SIZE 100

int queue[QUEUE_SIZE];
int front = 0;
int rear = 0;
int isempty = 0;

int y = -1;

inline mpty() 
{
    if
        ::(front!=rear)->
            isempty = 0;  
        ::else->
            isempty = 1;
    fi;
}

inline enqueue(item) 
{
    queue[rear] = item;
    rear = rear + 1;    
}

inline dequeue() 
{
    mpty();

    if 
        ::(isempty==0) 
            y = queue[front];
            front = front + 1;
        ::else-> 
            y = -1; 
    fi;
}
	
inline max(a, b) 
{
     if
        ::(a>b)->
            return a;
        ::else->
            return b;
     fi;
}

inline min(a, b) 
{
    if
        ::(a<b)->
            return a;
        ::else->
            return b;
    fi;
}


proctype Input(int cur_time_input)
{
    atomic
    {    
        if
            :: (cur_time_input < TIME) ->
                int req_floor = request[cur_time_input];
                request[cur_time_input] = NO;
                if
                    :: (req_floor != NO) ->
                        if
                            :: (cur_dir == 1) ->
                                if
                                    :: (req_floor - cur_floor >0) ->
                                        up_stop[req_floor] = true;
                                        max_up = max(max_up, req_floor);
                                    :: else ->
                                        if
                                            :: (down) ->
                                                down_stop[req_floor] = true;
                                                min_down = min(min_down, req_floor);
                                            ::else ->
                                                down = true;
                                                enqueue(req_floor);
                                                down_stop[req_floor] = true;
                                                min_down = min(min_down, req_floor);
                                        fi;
                                fi;
                            :: (cur_dir == -1) ->
                                if
                                    :: (req_floor - cur_floor < 0) ->
                                        down_stop[req_floor] = true;
                                        min_down = min(min_down, req_floor);
                                    :: else ->
                                        if
                                            :: (up) ->
                                                up_stop[req_floor] = true;
                                                max_up = max(max_up, req_floor);
                                            ::else ->
                                                up = true;
                                                enqueue(req_floor);
                                                up_stop[req_floor] = true;
                                                max_up = max(max_up, req_floor);
                                        fi;
                                fi;
                            ::else ->
                                if
                                    :: (req_floor - cur_floor > 0) ->
                                        up_stop[req_floor] = true;
                                        max_up = max(max_up, req_floor);
                                        enqueue(req_floor);
                                    :: else ->
                                        down_stop[req_floor] = true;
                                        min_down = min(min_down, req_floor);
                                        enqueue(req_floor);
                                fi;
                        fi;

                fi;
        fi;
    }   
}


int cur_time = 0;
int req_floor;

proctype Elevator()
{
    do
        :: (cur_time>=TIME) -> break;
        :: (cur_time <TIME) ->
            run Input(cur_time);
        mpty();
        if
            :: (isempty==1 && cur_dir == 0) ->
                isDoorOpen = true;
                cur_time = cur_time+1;
            :: (isempty==0 && cur_dir == 0) ->
                dequeue();
                req_floor = y;
            if
                :: (req_floor > cur_floor) -> 
                    isDoorOpen = false;
                    cur_dir = 1;
                    printf("Going up..\n");
                    do
                        ::true ->
                            printf("Elevator is currently at floor: %d and Time: %d\n", cur_floor, cur_time);
                            if
                                :: (max_up < cur_floor) -> 
                                    break; 
                                :: (max_up >= cur_floor) ->
                                    if
                                        :: (up_stop[cur_floor] == true) ->
                                            cur_dir = 0;
                                            isDoorOpen = true;
                                            printf("Door Opened at floor: %d\n", cur_floor);
                                            up_stop[cur_floor] = false;
                                            isDoorOpen = false;
                                            printf("Door closed at floor: %d\n", cur_floor);
                                            cur_dir = 1;
                                        :: else ->
                                            true;
                                    fi;
                            fi;

                            if
                                :: (cur_floor == max_up) ->
                                    max_up = 0;
                                    cur_dir = 0;
                                    isDoorOpen = true;
                                ::else ->
                                    cur_floor = cur_floor+1;
                            fi;
                        cur_time = cur_time+1;
                        run Input(cur_time);
                    od;
                :: else ->
                    isDoorOpen = false;
                    cur_dir = -1;
                    printf("Going down..\n");
                    do
                        ::true ->
                            printf("Elevator is currently at floor: %d and Time: %d\n", cur_floor, cur_time);
                            if
                                :: (min_down > cur_floor) -> 
                                    break; 
                                :: (min_down <= cur_floor) ->
                                    if
                                        :: (down_stop[cur_floor] == true) ->
                                            cur_dir = 0;
                                            isDoorOpen = true;
                                            printf("Door Opened at floor: %d\n", cur_floor);
                                            down_stop[cur_floor] = false;
                                            isDoorOpen = false;
                                            printf("Door closed at floor: %d\n", cur_floor);
                                            cur_dir = -1;
                                        :: else ->
                                            true;
                                    fi;
                            fi;

                            if
                                :: (cur_floor == min_down) ->
                                    min_down = TOTAL_FLOOR;
                                    cur_dir = 0;
                                    isDoorOpen = true;
                                ::else ->
                                    cur_floor = cur_floor-1;
                            fi;
                        cur_time = cur_time+1;
                        run Input(cur_time);
                    od;
            fi;
        fi;           
    od;
    printf("LoopExited\n");
}



init
{
    run Elevator();
    assert(cur_floor<=TOTAL_FLOOR && cur_floor>=0);        
}

ltl p1
{
    <>(isDoorOpen == true);                                                     //violated
}
ltl p2
{
    [](isDoorOpen == true implies cur_dir == 0);                                //satisfied    
}
ltl p4
{
    ((req_floor - cur_floor) < 0 implies <>(cur_dir == -1));                    //satisfied   
}
ltl p5
{    
    []<>(req_floor implies <>(req_floor == cur_floor && isDoorOpen == true));   //satisfied   
}
ltl p6
{
    [](cur_dir!=0 implies isDoorOpen==false)                                    //satisfied
}
ltl p7
{
   [](isDoorOpen==true implies <>(isDoorOpen==false))                            //satisfied
}
