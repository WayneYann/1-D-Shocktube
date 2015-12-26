      SUBROUTINE Update_RK
      USE Chem
      USE Global
      IMPLICIT NONE
      INTEGER :: I,NsI
      REAL*8 :: a
      REAL*8,EXTERNAL :: E_to_T
C     Update Variables for 3rd-Explicit_TVD Runge-Kutta 
C     ���߷������ӿ�
      INTERFACE 
          FUNCTION Secant( X0, a, Msf, F, Epsilon, MAX_Iter )
              USE Chem
              USE Global, ONLY: Ns
              IMPLICIT NONE
              REAL*8 :: Secant  
              REAL*8 :: a             
              REAL*8 :: Msf(Ns)                
              REAL*8 :: X0(2)          
              REAL*8 :: Epsilon    
              INTEGER :: MAX_Iter     
              REAL*8,EXTERNAL :: F       
          END FUNCTION Secant
      END INTERFACE
          
          F2=F0  ! F2 ֻ�ڵ����� RK ������ʹ��, ���� n ʱ�̱���
C                                                                 ��һ�� RK ������Ϊ��һ��ʱ������Ķ����м����
C                                                                 �ڶ��� RK ������ F2 Ϊ n ʱ�̱���
C                                                                 ������ RK ������Ϊһ���м����

          F0=F1  ! F0 ʼ���Ǳ�����ʱ�̱�����һʱ�̵ı��� �� ֻ�ڵڶ��� RK ������ʹ�ã�
C                                                         ��һ�� RK �������� n ʱ�̱���
C                                                         �ڶ��� RK �������� һ���м����
C                                                         ������ RK �������� �����м����
          F1=F   ! Fʼ�����м����
C                                  �ڵ�һ�� RK ������Ϊһ���м����
C                                  �ڵڶ��� RK ������Ϊ�����м����
C                                  �ڵ����� RK �������� n+1 ʱ�̱���


          DO I=1,N
C         From Conserved Variables to Primitive Variables

              Q1(1,I)=F1(1,I)                                                    ! rho   || F1 = rho
              Q1(2,I)=F1(2,I)/Q1(1,I)                                            ! u     || F2 = rho*u  || F3= rho*et

C             Mass Fraction
              DO NsI=1,Ns1
                  Q1(3+NsI,I)=F1(3+NsI,I)/Q1(1,I) 
              END DO
C             The Last Species is N2, which shall be determined by those of other species 
C                                                to maintain mass conservation of species
              Q1(NT,I)=1 - SUM( Q1(4:NT1,I) )

C             Get Temprature  || From �� Total Specific Internal Energy �� to Temperature
              a = F1(3,I)/F1(1,I) - 0.5*Q1(2,I)**2
              Tpt(I) = Secant( X0, a, Q1(4:NT,I), E_to_T, TOL_, 1000 )

C                 ht= SUM(Yi*hi) + 0.5*u^2 = et + R*T        ! R = Mean Gas Constant of the Mixture
C                 => F1(3,I)/F1(1,I) + R*T - [ SUM(Yi*hi) + 0.5*u^2 ] =0  || By Newton-Raphson( Secant Method ) Iterations
C                                                                         || F1(3,I), F1(1,I), R, Yi,u are KNOWN
C                                                                         || hi, T is UNKNOWN, and T is output

C             Pressure  [ g/(cm*s^2) ]
              CALL CKPY( Q1(1,I), Tpt(I), Q1(4:NT,I), IWORK, RWORK, Q1(3,I) )

C             Enthalpies at ��cell center�� of each species, use by Mass Diffusion terms
C             Units [ ergs/g ]
              CALL CKHMS( Tpt(I), IWORK, RWORK, H(:,I) )

          END DO
          
      END SUBROUTINE Update_RK








C=====================================Secant Method=====================================
      FUNCTION Secant( X0, a, Msf, F, Epsilon, MAX_Iter )
      USE Chem
      USE Global, ONLY: Ns
      IMPLICIT NONE
      REAL*8 :: Secant            ! �����ҵ������
      REAL*8 :: a                 ! �������������ʽ�еĳ����
      REAL*8 :: Msf(Ns)           ! Mass Fractions
      REAL*8 :: F1,F2             ! ����ʱ�ĺ���ֵ ( F1 ��ʾ��һ������, F2 ��ʾ��ǰ������ )
      REAL*8 :: X1,X2             ! ����ʱ���Ա��� ( X1 ��ʾ��һ������, X2 ��ʾ��ǰ������ )
      REAL*8 :: X0(2)             ! X0 ��ʾ�²�ĳ�ʼ��Χ
      REAL*8 :: Epsilon, DF       ! �����о�

      INTEGER :: MAX_Iter,I       ! ����������

      REAL*8,EXTERNAL :: F        ! ��������

C     NOTE:
C             ��ʼ������ֵ��ȷ�����Ա������䣬��һ��Ҫ������㡱 ������

C     ����ȷ����ʼ����ֵ
          X1=X0(1)
          X2=X0(2)
      
          F1=F( a, Msf, X1 )
          F2=F( a, Msf, X2 )

          DO I=1,MAX_Iter
          
              DF=ABS(F1-F2)
              !WRITE(1000,*)DF,X1
              IF ( DF.LT.Epsilon ) THEN
                  EXIT
              END IF

              Secant = X1 - F1*( X1-X2 )/( F1-F2 )

              F2=F1                       ! ���º���ֵ

              X2=X1                       ! �����Ա���
              X1=Secant           

              F1=F( a, Msf, Secant )      ! ȷ����ǰ������F1



          END DO

          IF ( DF.GT.Epsilon ) THEN
              WRITE(*,*) 'No solution...'
              PAUSE
              STOP
          END IF

      END FUNCTION Secant


C========================================Function E_to_T========================================
      FUNCTION E_to_T( a, Msf, T )
      USE Chem
      USE Global, ONLY: Ns,Mlw,R0
      IMPLICIT NONE
      REAL*8 :: E_to_T
C     F1(3,I)/F1(1,I) + R*T - [ SUM(Yi*hi) + 0.5*u^2 ] =0   !  R= R0/W_ || W_= 1 / SUM( Msf(I)/Mlw(I) )
C     
C                                                         <=>  a + R*T - SUM(Yi*hi) =0  || a = F1(3,I)/F1(1,I) - 0.5*u^2 
      REAL*8 :: a,T
      REAL*8 :: Msf(Ns)
      REAL*8 :: WTM,R,HBMS

      CALL Get_WTM( Msf, Mlw, WTM )                 ! 1_HLLEM.for\Get_WTM   | Mean molecular weight of the gas mixture
      R=R0/WTM 
      CALL CKHBMS( T, Msf, IWORK, RWORK, HBMS )     ! HBMS = Mean Specific Enthalpy of the Gas Mixture [ ergs/g ]

      E_to_T = a + R*T - HBMS

      END FUNCTION E_to_T
C===============================================================================================
                                         
C========================================Function H_to_T========================================
      FUNCTION H_to_T( a, Msf, T )
      USE Chem
      USE Global, ONLY: Ns
      IMPLICIT NONE
      REAL*8 :: H_to_T
C     Hs - SUM( Yi_s*hi(Ts) ) - 0.5*Us^2 =0   <=>  a - SUM(Yi*hi) =0  || a = Hs - 0.5*Us^2
     
      REAL*8 :: a,T
      REAL*8 :: Msf(Ns)
      REAL*8 :: HBMS

      CALL CKHBMS( T, Msf, IWORK, RWORK, HBMS )     ! HBMS = Mean Specific Enthalpy of the Gas Mixture [ ergs/g ]

      H_to_T = a - HBMS

      END FUNCTION H_to_T
C===============================================================================================
