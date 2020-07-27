
# July 27th, 2020
The tar file "results_isolation_old.tar.gz" contain preliminary simulations in which isolation considered that both symptomatic (I compartment) and hospitalized (H) where evacuated from the camp "instantly" and they had no contact at all with the camp.
In that case the parameter Isolate should be YES to consider any threshold, which had the meaning of isolation capacity.
Although the results where significant even for an evacuation capacity as low as 0.5% of the total population size, we felt that the assumptions where unrealistic and the parameters changed to have a different meaning.
In the current simulations, if Isolate = YES the hospitalized only are evacuated (H) and an isoThr>0 means that symptomatic (I) have isolation tents at their disposal to self-quarantine. They have contact with carers, under reduced probability of transmission (those of a safety zone) from the population class of healthy adults.
