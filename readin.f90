subroutine readin(jobs)
  use typedefs
  use nrtype
  implicit None
  integer :: info, ierr
  character(len=80) :: line, keyword
  type(joblist), intent(out) :: jobs

  write(881,*) "reading from input"

! Default value
  jobs%ne = 0

  open(unit = 101, file='input' , form ='formatted')
! do a loop thru input till the end of file
   
  do while(.true.)
    read(101,'(a80)',iostat=info) line 
    if (info<0) exit

! Skip comment lines
    if(len_trim(line).eq.0) cycle
    if(line(1:1).eq.'#') cycle
    if(line(1:1).eq.'!') cycle

! Determine keyword:
    keyword=line(1:scan(line," ")-1)
    line=adjustl(line(scan(line," ")+1:80))


    if(trim(keyword).eq.'ne') then
      read(line,*,iostat=ierr)  jobs%ne
    

    else
      write(881,*) 'ERROR: Unexpected keyword ', trim(keyword), ' was found in input.'
      call die("Unexpected keyword "//trim(keyword)//" found in input",0)
    endif
    if (ierr/=0) then
      write(881,*) 'ERROR: Fail when read ', trim(keyword), ' in input.'
      call die("Fail when read "//trim(keyword)//" in input",0)
    endif
      
  enddo


  write(881,'(a,i0)') " ne = ", jobs%ne
  write(881,*)
  

endsubroutine readin
