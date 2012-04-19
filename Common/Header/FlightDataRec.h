
#ifndef	FLIGHT_DATA_REC_H
#define	FLIGHT_DATA_REC_H
 

typedef struct{
	 int   abLog;
	 float fMin;
	 float fMax;
	 TCHAR szName[30];

	 int aiCheckInterval;
	 int aiMaxWarnings;
	 int aiWarningCnt;
}sFlightDataRec;


void InitFDR(void);
void UpdateFlightRecorder(void);
void OnExitFlightRecorder(void);
void OnCheckFDRRanges(void);

#endif
