      SUBROUTINE  Third_Explicit_TVD_RK
      USE Global
      IMPLICIT NONE
      INTEGER :: I,IP
C     3rd-Explitic TVD_Runge-Kutta ʱ���ƽ�



      Time=0.0_8

      DO WHILE (Time.LT.ETime)
      !DO Iter=1,100

C         Present Time
          Time=Time+dt
          WRITE(*,*)Time                              ! ��ǰ���㲽��Ӧ��ʱ��


C         ��1������
              CALL Re_Construct                       ! �ع� ( For Convective Flux )

              CALL Get_All_Convective_Flux            ! ����ͨ������

              !CALL Get_Transport                     ! ����ϵ������
              !CALL Get_All_Viscous_Flux              ! ճ��ͨ��
              !CALL Get_Source                        ! ��ӦԴ��
              DO I=1,N
                  IP=I+1
                  F(:,I)=F1(:,I) - dt/dh*( Gc(:,IP)-Gc(:,I) ) 
C     >                           + dt/dh*( Gv(:,IP)-Gv(:,I) ) 
C     >                           + dt*Gs(:,I)           
C                        ��ʱF1 Ϊ n ʱ�̱���, F Ϊһ���м����
              END DO

              CALL Update_RK                          ! ��������

              CALL BC                                 ! �߽�����

C         ��2������
              CALL Re_Construct    
              CALL Get_All_Convective_Flux  
              DO I=1,N
                  IP=I+1
                  F(:,I)=3.0/4.0*F0(:,I) + 1.0/4.0*F1(:,I) - 1.0/4.0*dt/dh*( Gc(:,IP)-Gc(:,I) )
C     >                                                     + 1.0/4.0*dt/dh*( Gv(:,IP)-Gv(:,I) ) 
C     >                                                     + 1.0/4.0*dt*Gs(:,I)   
C                                ��ʱF0Ϊ n ʱ�̱���, F1Ϊһ���м����, F Ϊ�����м���� 
              END DO
              CALL Update_RK                   
              CALL BC                               

C         ��3������
              CALL Re_Construct    
              CALL Get_All_Convective_Flux  
              DO I=1,N
                  IP=I+1
                  F(:,I)=1.0/3.0*F2(:,I) + 2.0/3.0*F1(:,I) - 2.0/3.0*dt/dh*( Gc(:,IP)-Gc(:,I) )
C     >                                                     + 2.0/3.0*dt/dh*( Gv(:,IP)-Gv(:,I) ) 
C     >                                                     + 2.0/3.0*dt*Gs(:,I)   
C                                ��ʱF2Ϊ n ʱ�̱���, F Ϊ n+1 ʱ�̱���, F1 Ϊ�����м���� 
              END DO
              CALL Update_RK                   
              CALL BC                               

      END DO

      END SUBROUTINE  Third_Explicit_TVD_RK