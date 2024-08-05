      program compute_connections
      implicit none

      double precision, allocatable :: r(:,:)
      double precision, allocatable :: rcut(:,:), rcut2(:,:)
      double precision :: cell(3)
      double precision :: xlo, xhi, ylo, yhi, zlo, zhi
      double precision :: rij2, rr

      integer, allocatable :: bonds(:,:)
      integer, allocatable :: bondsperatom(:)
      integer, allocatable :: attype(:)
      integer, allocatable :: atompertype(:)
      integer :: natom, ntype, natommax 
      integer :: frame, nframe 
      integer :: index, ii, jj
      integer :: i, j, k

      character*2, allocatable :: typelist(:)

      character*100 :: finLMP, foutCON

!!!!! Set Parameters !!!!!

	  finLMP = 'dump.backbones.lammpstrj'
	  natommax = 1000   !Set to some large number bigger than total possible number of atoms
      nframe = 100
	
!!!!! Read in Parameters !!!!!

      open(20,file='bond_defs.txt')
      read(20,*)
      read(20,*) ntype

      allocate (typelist(ntype))
      allocate (rcut(ntype,ntype),rcut2(ntype,ntype))

      !Get atom types
      read(20,*)
      do i=1,ntype
        read(20,*) index, typelist(index)
      enddo
      read(20,*)

      !Get bond cutoff definitions
      do i=1,ntype
        do j=i,ntype
          !write(*,*) i, j
          read(20,*) ii, jj, rcut(ii,jj)
          rcut(jj,ii) = rcut(ii,jj)
          rcut2(ii,jj) = rcut(ii,jj)*rcut(ii,jj)
          rcut2(jj,ii) = rcut2(ii,jj)
        enddo
      enddo

      close(20)

!!!!! Allocate Working Arrays !!!!!

      allocate (r(natommax,3))
      allocate (attype(natommax))

      allocate (bonds(natommax,natommax))
      allocate (bondsperatom(natommax))

!!!!! Get Connections !!!!!

      open(21,file=finLMP)

      do frame=1,nframe

        !!!!! Get Coordinates !!!!!
        read(21,*)
        read(21,*) !step
        read(21,*)
        read(21,*) natom   !natom can change for each frame 
        read(21,*)
        read(21,*) xlo, xhi
        read(21,*) ylo, yhi
        read(21,*) zlo, zhi
        read(21,*)

        cell(1) = xhi - xlo
        cell(2) = yhi - ylo
        cell(3) = zhi - zlo

        do i=1,natom
          read(21,*) index, attype(i), (r(i,j),j=1,3)
        enddo

        !!!!! Get Bonding Info !!!!!
        bondsperatom = 0

        do i=1,natom-1
         do j=i+1,natom
          rij2 = 0.0d0
          do k=1,3
            rr = r(i,k) - r(j,k)
            rr = rr - cell(k)*dfloat(nint(rr/cell(k)))
            rij2 = rij2 + rr*rr
          enddo
          if( rij2 .le. rcut2(attype(i),attype(j)) )then
            bondsperatom(i) = bondsperatom(i) + 1
            bondsperatom(j) = bondsperatom(j) + 1
            bonds(i,bondsperatom(i)) = j
            bonds(j,bondsperatom(j)) = i
          endif
         enddo
        enddo

        !!!!! Print Bonding Information !!!!!
		if(frame.ge.0      .and. frame.lt.10)      write(foutCON,9001) frame 
		if(frame.ge.10     .and. frame.lt.100)     write(foutCON,9002) frame 
		if(frame.ge.100    .and. frame.lt.1000)    write(foutCON,9003) frame 
		if(frame.ge.1000   .and. frame.lt.10000)   write(foutCON,9004) frame 
		if(frame.ge.10000  .and. frame.lt.100000)  write(foutCON,9005) frame 
		if(frame.ge.100000 .and. frame.lt.1000000) write(foutCON,9006) frame 
9001	format('connections/frame.',I1,'.txt')
9002	format('connections/frame.',I2,'.txt')
9003	format('connections/frame.',I3,'.txt')
9004	format('connections/frame.',I4,'.txt')
9005	format('connections/frame.',I5,'.txt')
9006	format('connections/frame.',I6,'.txt')
		
		open(30,file=foutCON)
		
        write(30,3000) natom, frame 
        write(30,3001)
3000    format(2I12)
3001    format('#ID  EL  NBONDS  BONDED_IDS')
        do i=1,natom
         write(30,3002) i, typelist(attype(i)), bondsperatom(i), (bonds(i,j),j=1,bondsperatom(i))
3002     format(I8,A4,I8,99I8)
        enddo

		close(30)

      enddo

      close(21)


!!!!! End Program !!!!!

      end





