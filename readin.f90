subroutine readin(jobs)
  use typedefs
  use nrtype
  implicit None
  integer :: info, ierr, ieh, i
  character(len=256) :: line, keyword
  type(joblist), intent(out) :: jobs

  write(881,*)
  write(881,*) "reading from input"

! Default value
  jobs%ne = 0
  jobs%lwbands = .false.
  jobs%lwkpoints = .true.
  jobs%nwstates = 0
  jobs%sigma = 0.05
  jobs%lsquare = .true.
  jobs%nbsv=0

  open(unit = 101, file='input' , form ='formatted')
! do a loop thru input till the end of file
   
  do while(.true.)
    read(101,'(a256)',iostat=info) line 
    if (info<0) exit

! Skip comment lines
    if(len_trim(line).eq.0) cycle
    if(line(1:1).eq.'#') cycle
    if(line(1:1).eq.'!') cycle

! Determine keyword:
    keyword=line(1:scan(line," ")-1)
    line=adjustl(line(scan(line," ")+1:256))


    if(trim(keyword).eq.'ne') then
      read(line,*,iostat=ierr)  jobs%ne
    
    elseif(trim(keyword).eq.'lwbands') then
      read(line,*,iostat=ierr)  jobs%lwbands

    elseif(trim(keyword).eq.'lwkpoints') then
      read(line,*,iostat=ierr)  jobs%lwkpoints

    elseif(trim(keyword).eq.'lsquare') then
      read(line,*,iostat=ierr)  jobs%lsquare

    elseif(trim(keyword).eq.'nwstates') then
      read(line,*,iostat=ierr) jobs%nwstates
      allocate(jobs%iwstates(jobs%nwstates))
!      jobs%iwstates=0
      do i=1, jobs%nwstates
        jobs%iwstates(i)=i
      enddo
    elseif(trim(keyword).eq.'iwstates') then
      read(line,*,iostat=ierr) jobs%iwstates
    elseif(trim(keyword).eq.'sigma') then
      read(line,*,iostat=ierr) jobs%sigma
    elseif(trim(keyword).eq.'nbsv') then
      read(line,*,iostat=ierr) jobs%nbsv

    else
      write(881,*) 'ERROR: Unexpected keyword ', trim(keyword), ' was found in input.'
      call die("Unexpected keyword "//trim(keyword)//" found in input",0)
    endif

    if (ierr/=0) then
      write(881,*) 'ERROR: Fail when read ', trim(keyword), ' in input.'
      write(881,*) line
      call die("Fail when read "//trim(keyword)//" in input",0)
    endif
      
  enddo

  if (jobs%ne /= 0) then
    write(881,'(a,i0)') " ne = ", jobs%ne
  endif
  write(881,'(a,l1)') " lwbands = ", jobs%lwbands
  write(881,'(a,l1)') " lwkpoints = ", jobs%lwkpoints
  if (jobs%nwstates .ne. 0) then
    write(881,'(a,i0)') " nwstates = ", jobs%nwstates
    write(881,'(a)') " iwstates = "
    do ieh = 1, jobs%nwstates
      write(881,'(i6)') jobs%iwstates(ieh)
    enddo ! ieh
    write(881,'(a,f7.5)') " sigma = ", jobs%sigma
  endif
  if (jobs%nbsv/=0) then
    write(881,'(a,i0)') " nbsv = ", jobs%nbsv
  endif
    

endsubroutine readin
