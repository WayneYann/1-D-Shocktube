      SUBROUTINE  Third_Explicit_TVD_RK
      USE Global
      IMPLICIT NONE
      INTEGER :: I,IP
C     3rd-Explitic TVD_Runge-Kutta ʱ���ƽ�



      SELECT CASE(IF_Continue)
          CASE(0)
          Time=0.0_8
          Iter=0
      END SELECT

      DO WHILE (Time.LT.ETime)
      !DO Iter=1,1
      Iter=Iter+1

C         Present Time
          Time=Time+dt
          WRITE(*,*)Time                              ! ��ǰ���㲽��Ӧ��ʱ��


C         ��1������
              CALL Re_Construct                       ! �ع� ( For Convective Flux )
              CALL Get_All_Convective_Flux            ! ����ͨ������

              SELECT  CASE( IF_Transport )
                  CASE(1)
                      CALL Get_All_Transport_Coefs            ! ����ϵ������
                      CALL Get_All_Viscous_Flux               ! ճ��ͨ��
              END SELECT
              SELECT CASE( IF_Reaction )
                  CASE(1)
                      CALL Get_All_Source                     ! ��ӦԴ��
              END SELECT

              DO I=1,N
                  IP=I+1
                  F(:,I)=F1(:,I) - dt/dh*( Gc(:,IP)-Gc(:,I) ) 
                  SELECT  CASE( IF_Transport )
                      CASE(1)
                          F(:,I) = F(:,I) + dt/dh*( Gv(:,IP)-Gv(:,I) )
                  END SELECT
                  SELECT CASE( IF_Reaction )
                      CASE(1)
                          F(:,I) = F(:,I) + dt*Gs(:,I) 
                  END SELECT
C     >                           + dt/dh*( Gv(:,IP)-Gv(:,I) ) 
C     >                           + dt*Gs(:,I)           
C                        ��ʱF1 Ϊ n ʱ�̱���, F Ϊһ���м����
              END DO

              CALL Update_RK                          ! ��������

              CALL BC                                 ! �߽�����

C         ��2������
              CALL Re_Construct    
              CALL Get_All_Convective_Flux  

              SELECT  CASE( IF_Transport )
                  CASE(1)
                      CALL Get_All_Transport_Coefs            ! ����ϵ������
                      CALL Get_All_Viscous_Flux               ! ճ��ͨ��
              END SELECT
              SELECT CASE( IF_Reaction )
                  CASE(1)
                      CALL Get_All_Source                     ! ��ӦԴ��
              END SELECT

              DO I=1,N
                  IP=I+1
                  F(:,I)=3.0/4.0*F0(:,I) + 1.0/4.0*F1(:,I) - 1.0/4.0*dt/dh*( Gc(:,IP)-Gc(:,I) )
                  SELECT  CASE( IF_Transport )
                      CASE(1)
                          F(:,I) = F(:,I) + 1.0/4.0*dt/dh*( Gv(:,IP)-Gv(:,I) ) 
                  END SELECT
                  SELECT CASE( IF_Reaction )
                      CASE(1)
                          F(:,I) = F(:,I) + 1.0/4.0*dt*Gs(:,I) 
                  END SELECT
C     >                                                     + 1.0/4.0*dt/dh*( Gv(:,IP)-Gv(:,I) ) 
C     >                                                     + 1.0/4.0*dt*Gs(:,I)   
C                                ��ʱF0Ϊ n ʱ�̱���, F1Ϊһ���м����, F Ϊ�����м���� 
              END DO
              CALL Update_RK                   
              CALL BC                               

C         ��3������
              CALL Re_Construct    
              CALL Get_All_Convective_Flux  

              SELECT  CASE( IF_Transport )
                  CASE(1)
                      CALL Get_All_Transport_Coefs            ! ����ϵ������
                      CALL Get_All_Viscous_Flux               ! ճ��ͨ��
              END SELECT
              SELECT CASE( IF_Reaction )
                  CASE(1)
                      CALL Get_All_Source                     ! ��ӦԴ��
              END SELECT

              DO I=1,N
                  IP=I+1
                  F(:,I)=1.0/3.0*F2(:,I) + 2.0/3.0*F1(:,I) - 2.0/3.0*dt/dh*( Gc(:,IP)-Gc(:,I) )
                  SELECT  CASE( IF_Transport )
                      CASE(1)
                          F(:,I) = F(:,I) + 2.0/3.0*dt/dh*( Gv(:,IP)-Gv(:,I) ) 
                  END SELECT
                  SELECT CASE( IF_Reaction )
                      CASE(1)
                          F(:,I) = F(:,I) + 2.0/3.0*dt*Gs(:,I)
                  END SELECT
C     >                                                     + 2.0/3.0*dt/dh*( Gv(:,IP)-Gv(:,I) ) 
C     >                                                     + 2.0/3.0*dt*Gs(:,I)   
C                                ��ʱF2Ϊ n ʱ�̱���, F Ϊ n+1 ʱ�̱���, F1 Ϊ�����м���� 
              END DO
              CALL Update_RK                   
              CALL BC 

          IF ( MOD(Iter,OutD).EQ.0 ) THEN
              CALL Output_Ins
          END IF                              

      END DO

      END SUBROUTINE  Third_Explicit_TVD_RK