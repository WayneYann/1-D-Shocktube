      SUBROUTINE  Third_Explicit_TVD_RK
      USE Global
      IMPLICIT NONE
      INTEGER :: I,IP
C     3rd-Explitic TVD_Runge-Kutta ʱ���ƽ�



      Time=0.0_8
      CALL Get_dt                                     ! ���ݳ�ʼ����ȷ��ͳһʱ�䲽��

      DO WHILE (Time.LT.ETime)
      !DO Iter=1,100

C         Present Time
          Time=Time+dt
          WRITE(*,*)Time                              ! ��ǰ���㲽��Ӧ��ʱ��


C         ��1������
              CALL Re_Construct                       ! �ع�
              CALL Get_All_Flux(Method)               ! ͨ������
              DO I=1,N
                  IP=I+1
                  F(:,I)=F1(:,I) - dt/dh*( G(:,IP)-G(:,I) )
              END DO
              CALL Update_RK                          ! ��������

              CALL BC                                 ! �߽�����

C         ��2������
              CALL Re_Construct    
              CALL Get_All_Flux(Method)   
              DO I=1,N
                  IP=I+1
                  F(:,I)=3.0/4.0*F0(:,I) + 1.0/4.0*F1(:,I) - 1.0/4.0*dt/dh*( G(:,IP)-G(:,I) )
              END DO
              CALL Update_RK                   
              CALL BC                               

C         ��3������
              CALL Re_Construct    
              CALL Get_All_Flux(Method)   
              DO I=1,N
                  IP=I+1
                  F(:,I)=1.0/3.0*F2(:,I) + 2.0/3.0*F1(:,I) - 2.0/3.0*dt/dh*( G(:,IP)-G(:,I) )
              END DO
              CALL Update_RK                   
              CALL BC                               

      END DO

      END SUBROUTINE  Third_Explicit_TVD_RK