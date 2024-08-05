      program identify_rxnstates
      implicit none

      integer, allocatable :: rxnstate(:,:)
      integer, allocatable :: ncomponent(:)
      integer, allocatable :: rxnstateUNIQUE(:,:)
      integer, allocatable :: ncomponentUNIQUE(:)
      integer, allocatable :: checkedcomp(:)
      integer, allocatable :: framerxnstate(:)

      integer :: nglobalIndex, nframe
      integer :: index, frame, component, descriptortype
      integer :: nrxnstate, statematch, speciesmatch
      integer :: i, j, k, l

!!!!! Get Parameters !!!!!

      open(20,file='control.txt')
      read(20,*) nglobalIndex
      close(20)

!!!!! Allocate Arrays !!!!!

      allocate (rxnstate(nglobalIndex,nglobalIndex))
      allocate (ncomponent(nglobalIndex))

      allocate (rxnstateUNIQUE(nglobalIndex,nglobalIndex))
      allocate (ncomponentUNIQUE(nglobalIndex))

      allocate (checkedcomp(nglobalIndex))

      allocate (framerxnstate(nglobalIndex))

!!!!! Reduce Structures to Reaction States !!!!!

      open(20,file='descriptors.txt')
      read(20,*)

      rxnstate      = -1
      ncomponent    =  0
      nframe        =  0

      do i=1,nglobalIndex
        read(20,*) index, frame, component, descriptortype
        frame = frame + 1   !offset so frame index starts at 1
        if(frame.ge.nframe) nframe = frame !identify maximum number of frames
        ncomponent(frame) = ncomponent(frame) + 1
        rxnstate( frame, ncomponent(frame) ) = descriptortype
      enddo

      close(20)

!!!!! Identify Unique Reaction States !!!!!

      nrxnstate         = 0
      framerxnstate    = -1

      do i=1,nframe

        !If first frame, then save as first unique RXNSTATE
        if(i.eq.1)then
          nrxnstate = nrxnstate + 1
          ncomponentUNIQUE(nrxnstate) = ncomponent(i)
          do j=1,ncomponent(i)
            rxnstateUNIQUE(nrxnstate,j) = rxnstate(i,j)
          enddo
          framerxnstate(i) = nrxnstate
        !If not first frame, then we need to check against library of RXNSTATEs
        else

          statematch = 0

          !Check against known unique reaction states
          do j=1,nrxnstate

            if( ncomponent(i).eq.ncomponentUNIQUE(j) )then
              !RXNSTATE could match, must check against library
              speciesmatch = 0
              checkedcomp  = 0

              !Compute speciesmatch value being careful not to count components multiple times
              do k=1,ncomponent(i)
                do l=1,ncomponent(i)  !l=1 or l=k?
                  if( rxnstate(i,k).eq.rxnstateUNIQUE(j,l) .and. checkedcomp(l).eq.0 )then
                    speciesmatch = speciesmatch + 1
                    checkedcomp(l) = 1
                  endif
                enddo
              enddo


              !If speciesmatch = ncomponent(i), then we matched an earlier record j and not unique
              if(speciesmatch.eq.ncomponent(i))then
                statematch = 1
                framerxnstate(i) = j
              endif

            else
              !Definitely doesn't match, do nothing
            endif

          enddo

          !If, after checking all rxnstates we have statematch = 0, then this frame's rxnstate is unique
          if(statematch.eq.0)then
            nrxnstate = nrxnstate + 1
            ncomponentUNIQUE(nrxnstate) = ncomponent(i)
            do j=1,ncomponent(i)
              rxnstateUNIQUE(nrxnstate,j) = rxnstate(i,j)
            enddo
            framerxnstate(i) = nrxnstate
          endif

        endif

      enddo


!!!!! Print RXNSTATE of each frame !!!!!

      open(30,file='rxnstates.txt')
      write(30,3000)
3000  format('#FRAME  RXNSTATETYPE  NCOMPONENTS  STRUCTURES')
      do i=1,nframe
        write(30,3001) i-1, framerxnstate(i), ncomponent(i), (rxnstate(i,j),j=1,ncomponent(i))
3001    format(99I12)
      enddo
      close(30)

!!!!! Print UNIQUE RXNSTATEs !!!!!

      open(31,file='unique.rxnstates.txt')
      write(31,3100)
3100  format('#RXNSTATETYPE  NCOMPONENTS  STRUCTURES')
      do i=1,nrxnstate
        write(31,3101) i, ncomponentUNIQUE(i), (rxnstateUNIQUE(i,j),j=1,ncomponentUNIQUE(i))
3101    format(99I12)
      enddo
      close(31)

!!!!! End Program !!!!!

      end
