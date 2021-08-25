subroutine date_time(bdate,btime)
  ! returns:
  ! - bdate: string with date
  ! - btime: string with time
  character(len=11), intent(out) :: bdate
  character(len=14), intent(out) :: btime

  integer :: lmonth
  integer :: idate(8)
  character(len=10) :: atime
  character(len=8) :: adate
  character(len=5) :: azone
  character(len=4) :: year
  character(len=3) :: month(12)
  character(len=2) :: hour, min, sec, day

  data month/'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep', &
       'Oct','Nov','Dec'/

  call date_and_time(adate,atime,azone,idate)
  read(adate,"(a4,i2,a2)") year, lmonth, day
  write(bdate,"(a2,a1,a3,a1,a4)") day, '-', month(lmonth), '-', year
  read(atime,'(a2,a2,a2,a4)') hour, min, sec
  write(btime,"(a2,a1,a2,a1,a2,1x,a5)") hour, ':', min, ':', sec, azone

  return
end subroutine date_time

subroutine die(str)!,id_cpu)
!  use mpi
  implicit none
  character (len=*) :: str
  integer :: ierr
!  integer, intent(In), optional :: id_cpu

  write(*,*)
  write(*,*) "Stop! ERROR in: ", trim(str)
!  if (present(id_cpu)) write(*,*) "At cpu",id_cpu
  write(*,*)
  stop
!  call MPI_Abort(MPI_COMM_WORLD, 0, ierr)

endsubroutine die
