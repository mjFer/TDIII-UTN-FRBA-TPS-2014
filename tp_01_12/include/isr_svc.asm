


[BITS 64]
;-----------------------------------------------------------
; Handler de ServiceCall
; Recibe: por Rbx el servicio a llamar
; Devuelve: Nada
;----------------------------------------------------------- 
Int80Han:
 cmp ebx,0  ;Servicio "Random" ebx=0
 je Rand_call
 cmp ebx,1
 je print64_call
 cmp ebx,2
 je call_itoa
 cmp ebx,3
 je jiffies_call	;current task ms
 cmp ebx,5
 je call_BCDtoa
 cmp ebx,6
 je t_id_call		;task id
  cmp ebx,7
 je t_pr_call		;task priority 
 cmp ebx,10
 je RTC_s_call
 cmp ebx,11
 je RTC_mn_call
  cmp ebx,12
 je RTC_hr_call
 cmp ebx,13
 je RTC_d_call
 cmp ebx,14
 je RTC_m_call
 cmp ebx,15
 je RTC_a_call
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
 
finInt80:
 iretq
