%include "include/isr_svc.mac"


[BITS 64]
;-----------------------------------------------------------
; Handler de ServiceCall
; Recibe: por Rbx el servicio a llamar
; Devuelve: Nada
;----------------------------------------------------------- 
Int80Han:
 cmp ebx,S_RANDOM  ;Servicio "Random" ebx=0
 je Rand_call
 cmp ebx,S_PRINT
 je print64_call
 cmp ebx,S_ITOA
 je call_itoa
 cmp ebx,S_JIFFIES
 je jiffies_call	;current task ms
 cmp ebx,S_BCDTOA
 je call_BCDtoa
 cmp ebx,S_T_ID
 je t_id_call		;task id
  cmp ebx,S_T_PR
 je t_pr_call		;task priority 
 cmp ebx,S_RTC_SEC
 je RTC_s_call
 cmp ebx,S_RTC_MIN
 je RTC_mn_call
  cmp ebx,S_RTC_HR
 je RTC_hr_call
 cmp ebx,S_RTC_DAY
 je RTC_d_call
 cmp ebx,S_RTC_MNTH
 je RTC_m_call
 cmp ebx,S_RTC_YR
 je RTC_a_call 
 cmp ebx,S_MSLEEP
 je mSleep_call
 jmp finInt80

 call_itoa:
    call my_itoa
    iretq
 call_BCDtoa:
    call my_BCDtoa
    iretq
 RTC_s_call:
    call RTC_Get_Seconds
    iretq
 RTC_mn_call:
    call RTC_Get_Minutes
    iretq
 RTC_hr_call:
    call RTC_Get_Hours
    iretq
 RTC_d_call:
    call RTC_Get_Day
    iretq   
 RTC_m_call:
    call RTC_Get_Month
    iretq   
 RTC_a_call:
    call RTC_Get_Year
    iretq
print64_call: 
    call Print_64
    iretq
jiffies_call:
    call jiffies
    iretq
t_id_call:		;task id
    call get_Task_ID
    iretq
t_pr_call:		;task priority
    call get_Task_Priority
    iretq   
Rand_call: 
    call Rand
mSleep_call:
    call mSleep
 
finInt80:
 iretq
