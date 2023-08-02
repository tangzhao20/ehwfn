! Calculate the electron/hole amplitude of exciton states
! Prepare for the weighted band structure plot
! |AvS(k)|^2=sum_c(AvckS^2)
! |AcS(k)|^2=sum_v(AvckS^2)
! where k is on the band structure path.


! input: nwstates, iwstates, nbsv
! read from files: labelinfo.dat(wannier), band.dat(wannier), kmap.dat(paratec), eqp.dat(BSE), eigenvectors(BSE)
! read from files: labelinfo.dat(wannier), band.dat(wannier), kgrid.log(BGW/MeanField/ESPRESSO/grid.x), eqp.dat(BSE), eigenvectors.h5(BSE)
! write to files: ebands_istate.dat

program ebands
  use typedefs
  use nrtype
  use mat
#ifdef HDF5
  use hdf5
#endif

  implicit none
  integer :: ns, nv, nc, nk, nh, noutk, nbsk, nbsv, nrk, ncplx
  integer :: ie, ik, ic, iv, is, iw, ih, ix, iy, iz, ib, ioutk, ibsk, irk, ik2, ib2, ikvbm, ne_all

  real(dp), allocatable :: Ae_rk(:,:,:,:) ! ns, nv, nc, nrk
  real(dp), allocatable :: Abk2(:,:)! nc+nv, noutk
  logical, allocatable :: lwwfn(:) ! j%ne
  real(dp), allocatable :: kk(:,:) ! 3, nk
  real(dp), allocatable :: outx(:) ! noutk
  integer, allocatable :: outind(:) ! noutk
  real(dp), allocatable :: khi(:,:) ! 3,nh
  real(dp), allocatable :: xhi(:) ! nh
  real(dp), allocatable :: eqp(:,:) ! nc+nv, nbsk
  real(dp), allocatable :: eqpx(:) ! nbsk
  real(dp), allocatable :: eqpout(:,:) ! nc+nv, noutk
  real(dp), allocatable :: eqpout2(:,:) ,eqpout3(:,:) ! nc+nv, noutk
  ! they are used to match the wannier to the inteqp
  real(dp), allocatable :: eqpall(:,:) ! nc+nv, nk
  integer, allocatable :: kmap(:) ! nk
  integer, allocatable :: kcount(:) ! nrk
  
  real(dp) :: kp(3), kpvbm(3), d1, d2, somefloat, ef, efall, vbmtmp
  type(joblist) :: jobs
  logical :: lbreak
  integer :: ierr

#ifdef HDF5
  real(dp), allocatable :: Ae_h5(:,:,:,:,:) ! ncplx, ns, nv, nc, nk
  integer(HID_T) :: file_id, data_id, dataspace_id, memspace_id ! hdf5 id
  integer(HSIZE_T) :: dims1(1), dims2(2), dims7(7), offset7(7), count7(7)
#endif

#ifdef CPLX
  complex(dpc), allocatable :: Ae(:,:,:,:) ! ns, nv, nc, nk
#else
  real(dp), allocatable :: Ae(:,:,:,:) ! ns, nv, nc, nk
#endif

  integer :: someint
  character(len=80) :: filename
  character(len=80) :: something
  character(len=11) :: cdate
  character(len=14) :: ctime

  open(unit=881,file="out.dat",status="replace")
  call date_time(cdate, ctime)
  write(881,'(a,a11,1x,a14)') " Start Time: ", cdate, ctime

  call readin(jobs)
  if (jobs%nwstates==0) then
    call die("jobs%nwstates=0. need input")
  endif
  if (jobs%nbsv==0) then
    call die("jobs%nbsv=0. need input")
  endif
  jobs%ne=maxval(jobs%iwstates)

  write(881,'(a)') " change ne to max(iwstates) "
  write(881,'(a,i0)') " ne = ", jobs%ne


  allocate(lwwfn(jobs%ne))
  lwwfn=.false.
  do iw =1, jobs%nwstates
    lwwfn(jobs%iwstates(iw))=.true.
  enddo ! iw

  write(881,*)
  write(881,*) "reading labelinfo.dat file"
  open(unit=21,file="labelinfo.dat",form="formatted",status="old")
  nh=0
  do
    read(21,"(6a)",iostat=ierr)
    if (ierr==0) then
      nh=nh+1
    else
      exit
    endif
  enddo
  rewind(21)
  allocate(khi(3,nh))
  allocate(xhi(nh))
  do ih=1,nh
    read(21,*) something, something, xhi(ih), khi(:,ih)
  enddo
  close(21) 
  write(881,'(a,i0)') " nh = ", nh

  write(881,*)
#ifdef HDF5
  if (jobs%lhdf5) then
    write(881,*) "reading file eigenvectors.h5 headers"
    dims1=1
    call h5open_f(ierr)
    call h5fopen_f("eigenvectors.h5", H5F_ACC_RDONLY_F, file_id, ierr)

    call h5dopen_f(file_id, "exciton_header/params/ns", data_id, ierr)
    call h5dread_f(data_id, H5T_NATIVE_INTEGER, ns, dims1, ierr)
    call h5dclose_f(data_id, ierr)

    call h5dopen_f(file_id, "exciton_header/params/nv", data_id, ierr)
    call h5dread_f(data_id, H5T_NATIVE_INTEGER, nv, dims1, ierr)
    call h5dclose_f(data_id, ierr)

    call h5dopen_f(file_id, "exciton_header/params/nc", data_id, ierr)
    call h5dread_f(data_id, H5T_NATIVE_INTEGER, nc, dims1, ierr)
    call h5dclose_f(data_id, ierr)

    call h5dopen_f(file_id, "exciton_header/kpoints/nk", data_id, ierr)
    call h5dread_f(data_id, H5T_NATIVE_INTEGER, nk, dims1, ierr)
    call h5dclose_f(data_id, ierr)
  else
#endif
    write(881,*) "reading file eigenvectors headers"
    open(unit=10,file="eigenvectors",form='unformatted',status='old')
    read(10) ns
    read(10) nv
    read(10) nc
    read(10) nk
#ifdef HDF5
  endif
#endif

  write(881,'(a,i0)') " ns = ", ns
  write(881,'(a,i0)') " nv = ", nv
  write(881,'(a,i0)') " nc = ", nc
  write(881,'(a,i0)') " nk = ", nk
  ne_all=ns*nv*nc*nk ! TODO: read from eigenvectors.h5

  allocate(kk(3,nk))
#ifdef HDF5
  if (jobs%lhdf5) then
    dims2=(/3,nk/)
    call h5dopen_f(file_id, "exciton_header/kpoints/kpts", data_id, ierr)
    call h5dread_f(data_id, H5T_NATIVE_DOUBLE, kk, dims2, ierr)
    call h5dclose_f(data_id, ierr)
  else
#endif
    read(10) kk(:,:) ! kpoints
#ifdef HDF5
  endif
#endif

  do ik=1,nk
    if (kk(1,ik)< -1.d-6) then
      kk(1,ik)=kk(1,ik)+1
    endif
    if (kk(2,ik)< -1.d-6) then
      kk(2,ik)=kk(2,ik)+1
    endif
    if (kk(3,ik)< -1.d-6) then
      kk(3,ik)=kk(3,ik)+1
    endif
  enddo

  write(881,*)
  write(881,*) "reading eqp.dat"
  allocate(eqpall(nv+nc,nk))
  open(unit=24,file="eqp.dat",form="formatted",status="old")
  do ik=1,nk
    read(24,*)
    do ib=1,nc+nv
      read(24,*) something, something, something, eqpall(ib,ik)
    enddo ! ib
  enddo ! ik
  close(24) 

  vbmtmp=-1.e10
  do ik=1,nk 
    if (eqpall(nv,ik)>vbmtmp) then
      vbmtmp=eqpall(nv,ik)
      kpvbm=kk(:,ik)
    endif
  enddo ! ik

  write(881,*) 
  open(unit=23,file="kmap.dat",form="formatted",status="old", iostat=ierr)
  if (ierr==0) then
    write(881,*) "reading kmap.dat file"
    read(23,*)
    read(23,*) nrk
    allocate(kmap(nk))
    allocate(kcount(nrk))
    kcount=0
    do ik=1, nk
      read(23,*) something, kp(:), irk
      kcount(irk)=kcount(irk)+1
      do ik2=1,nk
        if (max(dabs(kk(1,ik2)-kp(1)),dabs(kk(2,ik2)-kp(2)),dabs(kk(3,ik2)-kp(3)))<1.d-6) then
          kmap(ik2)=irk
          exit
        endif
      enddo
    enddo
    close(23)
  else
    open(unit=25,file="kgrid.log",form="formatted",status="old", iostat=ierr)
    if (ierr/=0) then
      write(*,*) "Error: neither kmap.dat (prt) or kgrid.log (qe) exist"
      stop
    endif
    write(881,*) "reading kgrid.log file"
    do
      read(25,'(a)',iostat=ierr) something
      if (ierr/=0) then
        write(*,*) "Error: EOF in kgrid.log"
        stop
      endif
      if (trim(something) .eq. "k-points in the irreducible wedge") then
        exit
      endif
    enddo
    read(25,*) nrk
    allocate(kmap(nk))
    allocate(kcount(nrk))
    do irk=1,nrk
      read(25,*) something, something, something, something, something, ik
      kcount(irk)=1
      kmap(ik)=irk
    enddo ! irk
    rewind(25)
    do
      read(25,'(a)',iostat=ierr) something
      if (ierr/=0) then
        write(*,*) "Error: EOF in kgrid.log"
        stop
      endif
      if (trim(something) .eq. "k-points in the original uniform grid") then
        exit
      endif
    enddo
    read(25,*) ! nk
    do ik=1,nk
      read(25,*) something, something, something, something, something, ik2
      if (ik2/=0) then
        kmap(ik)=kmap(ik2)
        kcount(kmap(ik))=kcount(kmap(ik))+1
      endif
    enddo ! ik
    close(25)
  endif

  write(881,*)
  write(881,*) "reading band.dat file"
  open(unit=22,file="band.dat",form="formatted",status="old")
  nbsk=0
  do
    read(22,"(2a4)",iostat=ierr) something, something
    if (something/="    ") then
      nbsk=nbsk+1
    else
      exit
    endif ! ierr==0
  enddo
  write(881,'(a,i0)') " nbsk = ", nbsk
  rewind(22)
!  nbsv=0
!  do
!    read(22,*,iostat=ierr) something, somefloat
!    if (ierr==0 .and. somefloat<1.d-6) then
!      nbsv=nbsv+1
!    else
!      exit
!    endif
!    do ik=1,nbsk
!      read(22,*)
!    enddo ! ik
!  enddo
!  write(881,'(a,i0)') " nbsv = ", nbsv
!  rewind(22)
  allocate(eqp(nv+nc,nbsk))
  allocate(eqpx(nbsk))

  do ik=1,nbsk
    read(22,*) eqpx(ik), something
  enddo ! ik
  rewind(22)

  do ib=1,jobs%nbsv-nv,1
    do ik=1,nbsk+1
      read(22,*)
    enddo ! ik
  enddo ! ib

  do iv=1,nv
    do ik=1,nbsk
      read(22,*) something, eqp(iv,ik)
    enddo ! ik
    read(22,*)
  enddo ! iv 
  do ic=1,nc
    do ik=1,nbsk
      read(22,*) something, eqp(nv+ic,ik)
    enddo ! ik
    read(22,*)
  enddo ! ic 

  close(22)

  ! align Fermi level to 0 eV
  ef=maxval(eqp(nv,:))
  do ib=1,nc+nv
    do ik=1,nbsk
      eqp(ib,ik)=eqp(ib,ik)-ef
    enddo ! ik
  enddo ! ib

  allocate(outx(1000))
  allocate(outind(1000))
  
  noutk=0
  write(881,*)
  write(881,*) "matching k points to the path"
  do ih=1,nh
    do ik=1,nk
      lbreak=.false.
      do ix=-1,1
        do iy=-1,1
          do iz=-1,1
            kp(1)=kk(1,ik)+dble(ix)
            kp(2)=kk(2,ik)+dble(iy)
            kp(3)=kk(3,ik)+dble(iz)
            if (dpp(kp,khi(:,ih))<=1.d-5) then
              noutk=noutk+1
              ioutk=noutk
              outind(ioutk)=ik
              outx(ioutk)=xhi(ih)
              lbreak=.true.
            endif
            if (ih<nh .and. dabs(xhi(ih)-xhi(ih+1))>1.d-6) then
              
              if (dpl(kp,khi(:,ih),khi(:,ih+1))<=1.d-5 .and. dot(kp-khi(:,ih),khi(:,ih+1)-khi(:,ih))>1.d-5 .and. dot(kp-khi(:,ih+1),khi(:,ih)-khi(:,ih+1))>1.d-5) then
                noutk=noutk+1
                ioutk=noutk
                outind(ioutk)=ik
                outx(ioutk)=xhi(ih)+(xhi(ih+1)-xhi(ih))*dpp(kp,khi(:,ih))/dpp(khi(:,ih+1),khi(:,ih))
                lbreak=.true.
              endif
            endif
            if (dpp(kp,kpvbm)<=1.d-5) then
              ikvbm=ik
            endif
            if (lbreak) then
              exit
            endif
          enddo ! iz
          if (lbreak) then
            exit
          endif
        enddo ! iy
        if (lbreak) then
          exit
        endif
      enddo ! ix

    enddo ! ik
  enddo ! ih

  deallocate(xhi)
  deallocate(khi)

  write(881,"(a)") " outind  outx  kk  :"
  do ih=1,noutk
    write(881,'(i5,4f8.3)') outind(ih), outx(ih), kk(:,outind(ih))
  enddo

  efall=maxval(eqpall(nv,:))-eqp(nv,ikvbm)+maxval(eqp(nv,:))
  ! TODO: if the VBM is not at the k-points sampling in eqp.dat
  do ik=1,nk
    do ib=1,nc+nv
      eqpall(ib,ik)=eqpall(ib,ik)-efall
    enddo ! ib
  enddo ! ik

  allocate(eqpout(nv+nc,noutk))
  allocate(eqpout2(nv+nc,noutk))
  allocate(eqpout3(nv+nc,noutk))

  do ioutk=1,noutk
    do ib=1,nc+nv
      eqpout2(ib,ioutk)=eqpall(ib,outind(ioutk))
    enddo ! ib
  enddo ! ik

  write(881,*)
  write(881,*) "doing eqp interpolation"
  do ioutk=1,noutk
    ibsk=1
    do
      if (eqpx(ibsk)<outx(ioutk)-1.d-5) then
        ibsk=ibsk+1
      elseif (dabs(eqpx(ibsk)-outx(ioutk)) < 2.d-5) then
        ibsk=ibsk
        d1=0.d0
        exit
      else
        ibsk=ibsk
        d1=outx(ioutk)-eqpx(ibsk)
        d2=eqpx(ibsk+1)-outx(ioutk)
        exit
      endif
    enddo
    if (dabs(d1)<1.d-6) then
      do ib=1,nv+nc
        eqpout3(ib,ioutk)=eqp(ib,ibsk)
      enddo ! ib
    else
      do ib=1,nv+nc
        eqpout3(ib,ioutk)=(eqp(ib,ibsk)*d2+eqp(ib,ibsk+1)*d1)/(d1+d2)
      enddo ! ib
    endif
  enddo ! ioutk

  write(881,*)
  write(881,*) "matching eqp"
  do ioutk=1,noutk
    do ib=1, nv+nc
      someint=1
      somefloat=1.d10
      do ib2=1,nv+nc
        if (dabs(eqpout3(ib2,ioutk)-eqpout2(ib,ioutk))<somefloat) then
          someint=ib2
          somefloat=dabs(eqpout3(ib2,ioutk)-eqpout2(ib,ioutk))
        endif
      enddo ! ib2
      eqpout(ib,ioutk)=eqpout3(someint,ioutk)
    enddo ! ib
  enddo ! ioutk

  write(881,*)
  write(881,*) "reading file eigenvectors"

#ifdef CPLX
  ncplx=2
#else
  ncplx=1
#endif

  allocate(Ae_rk(ns,nv,nc,nrk))
  allocate(Abk2(nc+nv,noutk))
#ifdef HDF5
  if (jobs%lhdf5) then
    dims1=(/ne_all/)
    call h5dopen_f(file_id, "exciton_data/eigenvectors", data_id, ierr)

    dims7=(/ncplx, ns, nv, nc, nk, ne_all, 1/)
    count7=(/ncplx, ns, nv, nc, nk, 1, 1/)
    dims1=product(count7)
    call h5screate_simple_f(1, dims1, memspace_id, ierr)
    allocate(Ae_h5(ncplx,ns,nv,nc,nk))
  else
#endif
    allocate(Ae(ns,nv,nc,nk))
#ifdef HDF5
  endif
#endif

  ! main loop:
  do ie = 1, jobs%ne
    if (lwwfn(ie) .eqv. .false.) then
#ifndef HDF5
      read(10) ! energy(ie)
      read(10) ! Aread(:)
#endif
      cycle
    endif

    Abk2=0.d0

#ifdef HDF5
    if (jobs%lhdf5) then
      offset7=(/0, 0, 0, 0, 0, ie-1, 0/)
      call h5dget_space_f(data_id, dataspace_id, ierr)
      call h5sselect_hyperslab_f(dataspace_id, H5S_SELECT_SET_F, offset7, count7, ierr)
      call h5dread_f(data_id, H5T_NATIVE_DOUBLE, Ae_h5, dims7, ierr, memspace_id, dataspace_id)
    else
#endif
      read(10) ! energy(ie)
      read(10) Ae
#ifdef HDF5
    endif
#endif

    Ae_rk=0.d0

    do ik = 1, nk
      do ic = 1, nc
        do iv = 1, nv
          do is = 1, ns
#ifdef HDF5
            if (jobs%lhdf5) then
#ifdef CPLX
              Ae_rk(is,iv,ic,kmap(ik))=Ae_rk(is,iv,ic,kmap(ik))+Ae_h5(1,is,iv,ic,ik)**2+Ae_h5(2,is,iv,ic,ik)**2
#else
              Ae_rk(is,iv,ic,kmap(ik))=Ae_rk(is,iv,ic,kmap(ik))+Ae_h5(1,is,iv,ic,ik)**2
#endif
            else
#endif
#ifdef CPLX
              Ae_rk(is,iv,ic,kmap(ik))=Ae_rk(is,iv,ic,kmap(ik))+dble(Ae(is,iv,ic,ik) * conjg(Ae(is,iv,ic,ik)))
#else
              Ae_rk(is,iv,ic,kmap(ik))=Ae_rk(is,iv,ic,kmap(ik))+Ae(is,iv,ic,ik)**2
#endif
#ifdef HDF5
            endif
#endif
          enddo ! is
        enddo ! iv
      enddo ! ic
    enddo ! ik

    do irk = 1, nrk
      do ic = 1, nc
        do iv = 1, nv
          do is = 1, ns
            Ae_rk(is,iv,ic,irk)=Ae_rk(is,iv,ic,irk)/dble(kcount(irk))
          enddo ! is
        enddo ! iv
      enddo ! ic
    enddo ! ik

    do ik = 1, nk
      do ioutk =1, noutk
        if (outind(ioutk)==ik) then
          do ic = 1, nc
            do iv = 1, nv
              do is = 1, ns
                Abk2(nv+1-iv,ioutk) = Abk2(nv+1-iv,ioutk) + Ae_rk(is,iv,ic,kmap(ik))
                Abk2(nv+ic,ioutk) = Abk2(nv+ic,ioutk) + Ae_rk(is,iv,ic,kmap(ik))
              enddo ! is
            enddo ! iv
          enddo ! ic
        endif ! outind(ioutk)==ik
      enddo ! ioutk
    enddo ! ik

    write(filename,'(a,i0,a)') "ebands_",ie,".dat"
    open(unit=16,file=filename,form="formatted",status="replace")
    write(16,'(a)') "# x, eqp(eV), AS^2(k)"
    do ib=1,nc+nv
      do ioutk=1,noutk
        write(16,'(f10.5,2f15.9)') outx(ioutk), eqpout(ib,ioutk), Abk2(ib,ioutk)
      enddo !ioutk
      write(16,*)
    enddo ! ib
  enddo ! ie

#ifdef HDF5
  if (jobs%lhdf5) then
    call h5sclose_f(memspace_id, ierr)
    call h5sclose_f(dataspace_id, ierr)
    call h5dclose_f(data_id, ierr)
    call h5fclose_f(file_id, ierr)
    call h5close_f(ierr)
    deallocate(Ae_h5)
  else
#endif
    close(10)
    deallocate(Ae)
#ifdef HDF5
  endif
#endif
  deallocate(Ae_rk)
  deallocate(Abk2)

  deallocate(lwwfn)
  deallocate(outind)
  deallocate(outx)
  deallocate(eqp)
  deallocate(eqpall)
  deallocate(eqpx)
  deallocate(eqpout)
  deallocate(eqpout2)
  deallocate(eqpout3)

  deallocate(kcount)
  deallocate(kmap)
  deallocate(kk)

  write(881,*) 
  call date_time(cdate, ctime)
  write(881,'(a,a11,1x,a14)') " End Time: ", cdate, ctime
endprogram ebands
