      PROGRAM MAIN
      USE Global
      IMPLICIT NONE

      CALL Set_Up                                 ! ���ÿ��Ʋ���

      CALL Initial                                ! ��ʼ������

      CALL TIME_Advance                           ! ʱ���ƽ�

      CALL Output                                 ! �������
      
      WRITE(*,*) 'Finished'
      PAUSE

      END PROGRAM
