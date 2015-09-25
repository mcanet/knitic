todo

- fix "error in pixel" -> OK
- fix corrupt data that stop the arduino -> OK
- check solenoid glitch -> close to be OK, much better with the fork of kinasmith
- check beltshift
- begin message to less error
- release solenoid when no connection -> ok
- maybe send two line

ayab
- initialisation
- active needle or not
- offset
- reset at the EOL

// Machine is initialized when left hall sensor is passed in Right direction
		if( Right == m_direction && Left == m_hallActive )
		{
			m_opState = s_ready;
			m_solenoids.setSolenoids(0xFFFF);
			return;
		}
		
if( (m_pixelToSet >= m_startNeedle-END_OF_LINE_OFFSET_L)
				&& (m_pixelToSet <= m_stopNeedle+END_OF_LINE_OFFSET_R)) // TODO ADD OFFSET
		{	// When inside the active needles
		}
		else
		{	// Outside of the active needles
