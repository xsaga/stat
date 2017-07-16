#!/usr/bin/awk -f

#awk 'BEGIN{FS=","; sum=0; min=100.0}{sum+=$3; if(min > $3) {min=$3; mem=$0}}END{print "NR ", NR, "Total ", sum, "AVR ", sum/NR "Mbit/s ", "\nmin speed ", min, "at ", mem}' speedtest-data.csv

#{data[NR]=$1}END{for(i=13; i>=0; i--){for(j=1;j<=NR;j++){ if(data[j]>=i){printf "|"}else{printf " "} }print ""}}

function round(num, dig){
    return int(num*(10^dig)+0.5)/(10^dig);
}

function data_plot(data, max, rmax, min, rmin, start, item_number){
    fmt = "%" ((length(rmax)>length(rmin))?length(rmax):length(rmin))+2 ".1f";
    for(i = max; i > 0; i--){
        printf fmt ".", round(rmax/max*i, 1);#(i==max)?rmax:" ";
        for(j = start; j <= item_number; j++){
            if(data[j]>=i){
                printf "|";
            }else{
                printf " ";
            }
        }
        print "";
    }

    printf fmt ".", 0;
    for(i = start; i <= item_number; i++){
        printf ".";
    }
    print "";

    for(i = -1; i > min; i--){
        printf fmt ".", (i==min+1)?rmin:" ";
        for(j = start; j <= item_number; j++){
            if(data[j]<=i){
                printf "|";
            }else{
                printf " ";
            }
        }
        print "";
    }
}

BEGIN{
    field_val = 1;
}

{
    if(NR == 1){
        min_val = $field_val;
        min_memory = $0;
        max_val = $field_val;
        max_memory = $0;
    }
}

{
    if(min_val > $field_val){
        min_val = $field_val;
        min_memory = $0;
    }

    if(max_val < $field_val){
        max_val = $field_val;
        max_memory = $0;
    }
    
    val_array[NR] = $field_val;
    sum += $field_val
}

END{
    avr = sum/NR;

    for(i in val_array){
        std_dev += (val_array[i] - avr)*(val_array[i] - avr); 
    }
    std_dev /= (NR-1);
    std_dev = sqrt(std_dev);

    printf "records/min/avg/max/std dev: %s/%s/%s/%s/%s\n", NR, min_val, avr, max_val, std_dev;

    for(elem in val_array){
        val_array[elem] = int(val_array[elem]*20/max_val+0.5);
    }
    data_plot(val_array, int(20.5), max_val, int(min_val*20/max_val+0.5), min_val, 1, NR);
}
