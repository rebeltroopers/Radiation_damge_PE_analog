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
      integer :: natom, ntype
      integer :: startframe, endframe, frame
      integer :: index, ii, jj
      integer :: i, j, k

      character*2, allocatable :: typelist(:)

      character*100 :: fin

!!!!! Set Parameters !!!!!

      open(20,file='control.txt')
      read(20,*) startframe, endframe
      read(20,*) fin
      close(20)

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

      open(21,file=fin)

      read(21,*)
      read(21,*) !step
      read(21,*)
      read(21,*) natom
      close(21)

      allocate (r(natom,3))
      allocate (attype(natom))

      allocate (bonds(natom,natom))
      allocate (bondsperatom(natom))

!!!!! Get Connections !!!!!

      open(21,file=fin)
      open(30,file='connections.txt')

      do frame=startframe,endframe

        !!!!! Get Coordinates !!!!!
        read(21,*)
        read(21,*) !step
        read(21,*)
        read(21,*) !natom
        read(21,*)
        read(21,*) xlo, xhi
        read(21,*) ylo, yhi
        read(21,*) zlo, zhi
        read(21,*)

        cell(1) = xhi - xlo
        cell(2) = yhi - ylo
        cell(3) = zhi - zlo

        do i=1,natom
          read(21,*) index, attype(index), (r(index,j),j=1,3)
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
        write(30,3000) natom, frame 
        write(30,3001)
3000    format(2I12)
3001    format('#ID  EL  NBONDS  BONDED_IDS')
        do i=1,natom
         write(30,3002) i, typelist(attype(i)), bondsperatom(i), (bonds(i,j),j=1,bondsperatom(i))
3002     format(I8,A4,I8,99I8)
        enddo



      enddo

      close(21)
      close(30)

!!!!! End Program !!!!!

      end





