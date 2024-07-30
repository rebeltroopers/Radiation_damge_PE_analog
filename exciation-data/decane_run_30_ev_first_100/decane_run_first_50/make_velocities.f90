      program make_velocities
      implicit none

      double precision, allocatable :: r(:,:)
      double precision, allocatable :: v(:,:)
      double precision, allocatable :: mass(:)

      double precision :: cell(3,3)
      double precision :: Vcm(3)
      double precision :: totmass
      double precision :: lx, ly, lz, xy, xz, yz
      double precision :: xloBound, xhiBound
      double precision :: yloBound, yhiBound
      double precision :: zloBound, zhiBound
      double precision :: xlo, xhi, ylo, yhi, zlo, zhi
      double precision :: randU1, randU2
      double precision :: randN1, randN2
      double precision :: Ttherm, Texcite, Temp, KEexcite, KE

      double precision, parameter :: pi=4.0d0*atan(1.0d0)
      double precision, parameter :: Na=6.022140857d23
      double precision, parameter :: kB=1.38064852d-23

      integer, allocatable :: attype(:)

      integer :: natom, ntype
      integer :: excitedatom, seed
      integer :: i, j, index, exitloop

      character*2, allocatable :: eltypes(:)

!!!!! Set Parameters !!!!!

      ntype = 2

      allocate (mass(ntype))
      allocate (eltypes(ntype))

      mass(1) = 12.011d0/(1.0d3*Na)
      eltypes(1) = 'C'

      mass(2) = 1.0079d0/(1.0d3*Na)
      eltypes(2) = 'H'

      !mass(2) = 18.998d0/(1.0d3*Na)
      !eltypes(2) = 'F'

      open(20,file='control.txt')
      read(20,*) Ttherm, Texcite
      read(20,*) excitedatom
      read(20,*) seed
      close(20)

      KEexcite = 3.0d0*kB*Texcite/2.0d0

!!!!! Get LAMMPS File !!!!!

      open(20,file='dump.final.pe.lammpstrj')

      read(20,*)
      read(20,*)
      read(20,*)
      read(20,*) natom
      read(20,*)
      read(20,*) xloBound, xhiBound, xy
      read(20,*) yloBound, yhiBound, xz
      read(20,*) zloBound, zhiBound, yz
      read(20,*)

      allocate (r(natom,3))
      allocate (attype(natom))

      do i=1,natom
        read(20,*) index, attype(index), (r(index,j),j=1,3)
      enddo

      close(20)

!!!!! Cell Vector Definitions !!!!!

      xlo = xloBound - MIN(0.0d0,xy,xz,xy+xz)
      xhi = xhiBound - MAX(0.0d0,xy,xz,xy+xz)
      ylo = yloBound - MIN(0.0d0,yz)
      yhi = yhiBound - MAX(0.0d0,yz)
      zlo = zloBound
      zhi = zhiBound

      lx = xhi - xlo
      ly = yhi - ylo
      lz = zhi - zlo

      cell = 0.0d0
      cell(1,1) = lx
      cell(2,1) = xy
      cell(2,2) = ly
      cell(3,1) = xz
      cell(3,2) = yz
      cell(3,3) = lz

!!!!! Write GEN File !!!!!

      open(30,file='system.gen')

      write(30,3001) natom
      write(30,3002) (eltypes(i),i=1,ntype)

3001  format(I8,' S')
3002  format(99A3)
3003  format(I8,I4,3F20.8)
3004  format(3F20.8)

      do i=1,natom
        write(30,3003) i, attype(i), (r(i,j),j=1,3)
      enddo

      write(30,3004) 0.0d0, 0.0d0, 0.0d0

      do i=1,3
        write(30,3004) (cell(i,j),j=1,3)
      enddo

      close(30)

!!!!! Make Velocities !!!!!

      call SRAND(seed)

      allocate (v(natom,3))

      do i=1,natom
        do j=1,3

          !Generate UNIFORM random numbers on [0,1]
          randU1 = rand()
          randU2 = rand()

          !Use Box-Muller to get Gaussian Random Numbers
          randN1 = dsqrt(-2.0d0*dlog(randU1))*dcos(2.0d0*pi*randU2)
          !randN2 = dsqrt(-2.0d0*dlog(randU1))*dsin(2.0d0*pi*randU2) !don't need this one

          !Assign a "thermal" velocity
          v(i,j) = dsqrt(kB*Ttherm/mass(attype(i)))*randN1

        enddo
      enddo

      !Make sure excited atom has exact KE corresponding to Texcite

      exitloop = 0

      do

        !Assign Velocity to Excited Atom
        do j=1,3
          !Generate UNIFORM random numbers on [0,1]
          randU1 = rand()
          randU2 = rand()
          !Use Box-Muller to get Gaussian Random Numbers
          randN1 = dsqrt(-2.0d0*dlog(randU1))*dcos(2.0d0*pi*randU2)
          !Assign a "excited" velocity
          v(excitedatom,j) = dsqrt(kB*Texcite/mass(attype(excitedatom)))*randN1
        enddo

        !Compute excited atom's KE
        KE = 0.0d0
        do j=1,3
          KE = KE + 0.5d0*mass(attype(excitedatom))*v(excitedatom,j)*v(excitedatom,j)
        enddo
        Temp = KE*2.0d0/(3.0d0*kB)
        !write(*,*) Temp
        if(dabs(Temp-Texcite).lt.1.0d0) exitloop = 1

        !Exit loop if condition met
        if(exitloop.eq.1)then
          exit
        endif

      enddo

!!!!! Remove COM velocity !!!!!

      Vcm = 0.0d0
      totmass = 0.0d0

      do i=1,natom
        totmass = totmass + mass(attype(i))
        do j=1,3
          Vcm(j) = Vcm(j) + mass(attype(i))*v(i,j)
        enddo
      enddo

      do j=1,3
        Vcm(j) = Vcm(j)/totmass
      enddo

      do i=1,natom
        do j=1,3
          v(i,j) = v(i,j) - Vcm(j)
        enddo
      enddo

!!!!! Compute Temperature !!!!!

      Temp = 0.0d0

      do i=1,natom
        do j=1,3
          Temp = Temp + 0.5d0*mass(attype(i))*v(i,j)*v(i,j)
        enddo
      enddo
      Temp = Temp*2.0d0/(3.0d0*dfloat(natom)*kB)
      write(*,*) Temp

!!!!! Print Velocities !!!!!

      open(30,file='velocities.txt')

      do i=1,natom
        write(30,3000) (v(i,j),j=1,3)
3000    format(3ES20.8)
      enddo

      close(30)

!!!!! End Program !!!!!

      end

