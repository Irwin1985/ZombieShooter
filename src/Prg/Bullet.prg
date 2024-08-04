USING System.Collections.Generic
USING System.Drawing
USING System.Windows.Forms

PUBLIC CLASS Bullet
	PUBLIC cDirection AS STRING
	PUBLIC nBulletLeft AS INT
	PUBLIC nBulletTop AS INT
	PRIVATE nSpeed := 20 AS INT
	PRIVATE oBullet := PictureBox{} AS PictureBox
	PRIVATE oTimer := Timer{} AS Timer
	
	PUBLIC METHOD MakeBullet(toForm AS Form) AS VOID
		oBullet:BackColor := Color.White
		oBullet:Size := Size{5, 5}
		oBullet:Tag := "bullet"
		oBullet:Left := nBulletLeft
		oBullet:Top := nBulletTop
		oBullet:BringToFront()
		
		toForm:Controls:Add(oBullet)
		
		oTimer:Interval := nSpeed
		oTimer:Enabled := TRUE
		oTimer:Tick +=EventHandler{ BulletTimerTick }
		oTimer:Start()
	END METHOD
	
	PRIVATE METHOD BulletTimerTick(sender AS OBJECT, e AS EventArgs) AS VOID
		IF cDirection:Equals("left")
			oBullet:Left -= nSpeed
		ENDIF
		
		IF cDirection:Equals("right")
			oBullet:Left += nSpeed
		ENDIF
		
		IF cDirection:Equals("up")
			oBullet:Top -= nSpeed
		ENDIF
		
		IF cDirection:Equals("down")
			oBullet:Top += nSpeed
		ENDIF
		
		IF oBullet:Left < 10 .or. oBullet:Left > 860 .or. oBullet:Top < 10 .or. oBullet:Top > 800
			oTimer:Stop()
			oTimer:Dispose()
			oBullet:Dispose()
			oTimer := NULL
			oBullet := NULL
		ENDIF
			
	END METHOD
		
	
END CLASS
