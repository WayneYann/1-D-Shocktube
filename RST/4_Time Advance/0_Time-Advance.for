      SUBROUTINE TIME_Advance
      USE Global

      
      SELECT CASE(T_Kind)
          CASE(2)
C         ������ͨ��ʽ ʱ���ƽ�
              CALL Second_Explicit

          CASE(3)
C         ������ʽ TVD_Runge-Kutta ʱ���ƽ�
              CALL Third_Explicit_TVD_RK

          CASE(4)
C         ������ʽ LUSGS ʱ���ƽ�
              CALL Second_Implicit_LUSGS

      END SELECT
      

      END SUBROUTINE TIME_Advance

      SUBROUTINE Get_dt
      USE Global
      IMPLICIT NONE
      REAL*8 :: S,Smax
      INTEGER :: I

          Smax=0.0
          DO I=1,N
              
              S=ABS( Q1(2,I) )+SQRT( Gamma*Q1(3,I)/Q1(1,I) )
                  
              IF ( S.GE.Smax) THEN
                  Smax=S
              END IF
          END DO
          
          dt=CFL*dh/Smax
  
      END SUBROUTINE Get_dt