//
// Defines used for advanced performance profiling of subsystems.
// Currently used only by SSoverlays (2018-02-24 ~Leshana)
//
#define STAT_ENTRY_TIME 1
#define STAT_ENTRY_COUNT 2
#define STAT_ENTRY_LENGTH 2

#define STAT_START_STOPWATCH var/STAT_STOP_WATCH = TICK_USAGE
#define STAT_STOP_STOPWATCH var/STAT_TIME = TICK_USAGE_TO_MS(STAT_STOP_WATCH)
#define STAT_LOG_ENTRY(entrylist, entryname) \
	var/list/STAT_ENTRY = entrylist[entryname] || (entrylist[entryname] = new /list(STAT_ENTRY_LENGTH));\
	STAT_ENTRY[STAT_ENTRY_TIME] += STAT_TIME;\
	var/STAT_INCR_AMOUNT = min(1, 2**round((STAT_ENTRY[STAT_ENTRY_COUNT] || 0)/SHORT_REAL_LIMIT));\
	if (STAT_INCR_AMOUNT == 1 || prob(100/STAT_INCR_AMOUNT)) {\
		STAT_ENTRY[STAT_ENTRY_COUNT] += STAT_INCR_AMOUNT;\
	};\
