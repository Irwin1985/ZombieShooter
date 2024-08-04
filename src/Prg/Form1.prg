USING System.Windows.Forms
USING System.Drawing
USING System.Collections.Generic
USING System.Linq

CLASS BasicForm INHERIT System.Windows.Forms.Form

	PROTECT oGameTimer AS System.Windows.Forms.Timer
	PROTECT oTimerPause AS System.Windows.Forms.Timer
	PROTECT otxtPause AS System.Windows.Forms.Label
	PROTECT oHealthBar AS System.Windows.Forms.ProgressBar
	PROTECT otxtHealth AS System.Windows.Forms.Label
	PROTECT otxtScore AS System.Windows.Forms.Label
	PROTECT otxtAmmo AS System.Windows.Forms.Label
	PROTECT oPlayer AS System.Windows.Forms.PictureBox
	// User code starts here (DO NOT remove this line)  ##USER##
    
	PRIVATE bGoLeft AS LOGIC
	PRIVATE bGoRight AS LOGIC
	PRIVATE bGoUp AS LOGIC
	PRIVATE bGoDown AS LOGIC
	PRIVATE bGameOver AS LOGIC
	PRIVATE cFacing := "up" AS STRING
	PRIVATE nPlayerHealth := 100 AS INT
	PRIVATE bPaused := FALSE AS LOGIC
	
	PRIVATE nSpeed := 10 AS INT
	PRIVATE nAmmo := 10 AS INT
	PRIVATE nScore := 0 AS INT
	PRIVATE nZombieSpeed := 3 AS INT
	PRIVATE oRandom := Random{} AS Random
	PRIVATE oZombieList := List<PictureBox>{} AS List<PictureBox>
	PRIVATE oResourceManager AS System.Resources.ResourceManager	


	CONSTRUCTOR()	
		SUPER()
		oResourceManager := System.Resources.ResourceManager{ "Designers" , System.Reflection.Assembly.GetExecutingAssembly() }
		SELF:InitializeForm()
		RestartGame()				
	END CONSTRUCTOR

	METHOD InitializeForm() AS VOID
	
	// IDE generated code (please DO NOT modify)
	
		SELF:oGameTimer := System.Windows.Forms.Timer{}
		SELF:oTimerPause := System.Windows.Forms.Timer{}
		SELF:otxtPause := System.Windows.Forms.Label{}
		SELF:oHealthBar := System.Windows.Forms.ProgressBar{}
		SELF:otxtHealth := System.Windows.Forms.Label{}
		SELF:otxtScore := System.Windows.Forms.Label{}
		SELF:otxtAmmo := System.Windows.Forms.Label{}
		SELF:oPlayer := System.Windows.Forms.PictureBox{}

		SELF:oGameTimer:Enabled := TRUE
		SELF:oGameTimer:Interval := 33
		SELF:oGameTimer:Tick += SELF:MainTimerEvent

		SELF:oTimerPause:Interval := 500
		SELF:oTimerPause:Tick += SELF:TimerPauseTick

		SELF:SuspendLayout()

		SELF:BackColor := System.Drawing.Color.FromArgb( 64,64,64 )
		SELF:ClientSize := System.Drawing.Size{940 , 700}
		SELF:KeyDown += SELF:OnKeyDown
		SELF:KeyUp += SELF:OnKeyUp
		SELF:Location := System.Drawing.Point{100 , 100}
		SELF:Name := "BasicForm"
		SELF:StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen
		SELF:Text := "Zombie Shooter Game"

		SELF:otxtPause:AutoSize := TRUE
		SELF:otxtPause:BackColor := System.Drawing.Color.Transparent
		SELF:otxtPause:Font := System.Drawing.Font{ "Microsoft Sans Serif" , 48.0 , System.Drawing.FontStyle.Regular }
		SELF:otxtPause:ForeColor := System.Drawing.Color.FromArgb( 255,255,255 )
		SELF:otxtPause:Location := System.Drawing.Point{324 , 308}
		SELF:otxtPause:Name := "txtPause"
		SELF:otxtPause:Size := System.Drawing.Size{293 , 84}
		SELF:otxtPause:TabIndex := 5
		SELF:otxtPause:Text := "PAUSED"
		SELF:otxtPause:Visible := FALSE
		SELF:Controls:Add(SELF:otxtPause)
		
		SELF:oHealthBar:Location := System.Drawing.Point{696 , 16}
		SELF:oHealthBar:Name := "HealthBar"
		SELF:oHealthBar:Size := System.Drawing.Size{232 , 23}
		SELF:oHealthBar:TabIndex := 3
		SELF:oHealthBar:Value := 100
		SELF:Controls:Add(SELF:oHealthBar)
		
		SELF:otxtHealth:AutoSize := TRUE
		SELF:otxtHealth:BackColor := System.Drawing.Color.Transparent
		SELF:otxtHealth:Font := System.Drawing.Font{ "Microsoft Sans Serif" , 14.25 , System.Drawing.FontStyle.Regular }
		SELF:otxtHealth:ForeColor := System.Drawing.Color.FromArgb( 255,255,255 )
		SELF:otxtHealth:Location := System.Drawing.Point{624 , 16}
		SELF:otxtHealth:Name := "txtHealth"
		SELF:otxtHealth:Size := System.Drawing.Size{69 , 27}
		SELF:otxtHealth:TabIndex := 2
		SELF:otxtHealth:Text := "Health:"
		SELF:Controls:Add(SELF:otxtHealth)
		
		SELF:otxtScore:AutoSize := TRUE
		SELF:otxtScore:BackColor := System.Drawing.Color.Transparent
		SELF:otxtScore:Font := System.Drawing.Font{ "Microsoft Sans Serif" , 14.25 , System.Drawing.FontStyle.Regular }
		SELF:otxtScore:ForeColor := System.Drawing.Color.FromArgb( 255,255,255 )
		SELF:otxtScore:Location := System.Drawing.Point{280 , 16}
		SELF:otxtScore:Name := "txtScore"
		SELF:otxtScore:Size := System.Drawing.Size{65 , 27}
		SELF:otxtScore:TabIndex := 1
		SELF:otxtScore:Text := "Kills: 0"
		SELF:Controls:Add(SELF:otxtScore)
		
		SELF:otxtAmmo:AutoSize := TRUE
		SELF:otxtAmmo:BackColor := System.Drawing.Color.Transparent
		SELF:otxtAmmo:Font := System.Drawing.Font{ "Microsoft Sans Serif" , 14.25 , System.Drawing.FontStyle.Regular }
		SELF:otxtAmmo:ForeColor := System.Drawing.Color.FromArgb( 255,255,255 )
		SELF:otxtAmmo:Location := System.Drawing.Point{24 , 16}
		SELF:otxtAmmo:Name := "txtAmmo"
		SELF:otxtAmmo:Size := System.Drawing.Size{85 , 27}
		SELF:otxtAmmo:TabIndex := 0
		SELF:otxtAmmo:Text := "Ammo: 0"
		SELF:Controls:Add(SELF:otxtAmmo)
		
		SELF:oPlayer:BackColor := System.Drawing.Color.Transparent
		SELF:oPlayer:BorderStyle := System.Windows.Forms.BorderStyle.None
		SELF:oPlayer:Location := System.Drawing.Point{434 , 576}
		SELF:oPlayer:Name := "Player"
		SELF:oPlayer:Size := System.Drawing.Size{73 , 102}
		SELF:oPlayer:SizeMode := System.Windows.Forms.PictureBoxSizeMode.AutoSize
		SELF:Controls:Add(SELF:oPlayer)
		
		SELF:ResumeLayout()

	RETURN

	METHOD MainTimerEvent(sender AS System.Object , e AS System.EventArgs) AS VOID
		IF bPaused
			oTimerPause:Start()
			RETURN
		ENDIF
		otxtPause:Visible := FALSE
		oTimerPause:Stop()
		
		IF nPlayerHealth > 1
			oHealthBar:Value := nPlayerHealth
		ELSE
			bGameOver := TRUE
			oPlayer:Image := (System.Drawing.Bitmap)oResourceManager:GetObject("dead.png")
			oGameTimer:Stop()
		ENDIF
		
		otxtAmmo:Text := i"Ammo: {nAmmo}"
		otxtScore:Text := i"Kills: {nScore}"
		
		IF bGoLeft .and. oPlayer:Left > 0
			oPlayer:Left -= nSpeed
		ENDIF
		
		IF bGoRight .and. (oPlayer:Left + oPlayer:Width < ClientSize:Width)
			oPlayer:Left += nSpeed
		ENDIF
		
		IF bGoUp .and. oPlayer:Top > 45
			oPlayer:Top -= nSpeed
		ENDIF
		
		IF bGoDown .and. (oPlayer:Top + oPlayer:Height < ClientSize:Height)
			oPlayer:Top += nSpeed
		ENDIF
		
		// Collect all  ammos
		LOCAL loPictureBoxList := Controls:OfType<PictureBox>():ToList() AS List<PictureBox>
		LOCAL lnHealth := 4 AS INT
		FOREACH loControl AS PictureBox IN loPictureBoxList			
			// get all zombies
			LOCAL loZombies := loPictureBoxList:Where({pb => (STRING)pb:Tag == "zombie"}):ToList() AS List<PictureBox>
			// check if any zombie is colliding with the player
			FOREACH loZombie AS PictureBox IN loZombies
				IF loZombie:Bounds:IntersectsWith(oPlayer:Bounds)					
					lnHealth--
					IF lnHealth <= 0
						nPlayerHealth--
						lnHealth := 4
					ENDIF
				ENDIF
			END FOR
			
			SWITCH ((PictureBox)loControl):Tag
			CASE "ammo"
				LOCAL loAmmo := (PictureBox)loControl AS PictureBox
				IF oPlayer:Bounds:IntersectsWith(loAmmo:Bounds)
					Controls:Remove(loAmmo)
					loAmmo:Dispose()
					// increase the ammo counter
					nAmmo += 5
				ENDIF
			CASE "zombie"
				LOCAL loZombie := (PictureBox)loControl AS PictureBox
				IF loZombie:Left > oPlayer:Left
					loZombie:Left -= nZombieSpeed
					loZombie:Image := (System.Drawing.Bitmap)oResourceManager:GetObject("zleft.png")
				ENDIF
				
				IF loZombie:Left < oPlayer:Left
					loZombie:Left += nZombieSpeed
					loZombie:Image := (System.Drawing.Bitmap)oResourceManager:GetObject("zleft.png")
				ENDIF
				
				IF loZombie:Top > oPlayer:Top
					loZombie:Top -= nZombieSpeed
					loZombie:Image := (System.Drawing.Bitmap)oResourceManager:GetObject("zup.png")
				ENDIF
				
				IF loZombie:Top < oPlayer:Top
					loZombie:Top += nZombieSpeed
					loZombie:Image := (System.Drawing.Bitmap)oResourceManager:GetObject("zdown.png")
				ENDIF
			CASE "bullet"
				LOCAL loBullet := (PictureBox)loControl AS PictureBox
				// check if the bullet is colliding with any zombie				
				FOREACH loZombie AS PictureBox IN loZombies
					IF loBullet:Bounds:IntersectsWith(loZombie:Bounds)
						nScore++
						// Eliminar la bala de la escena (formulario)
						Controls:Remove(loBullet)
						// Eliminar el zombie de la escena (formulario)
						Controls:Remove(loZombie)
						// Eliminar el zombie de la lista de zombies
						oZombieList:Remove(loZombie)
						// Liberar los objetos
						loBullet:Dispose()
						loZombie:Dispose()
						// Crear otro zombie
						MakeZombies()
					ENDIF
				END FOR
			END SWITCH			
		END FOR
				
	END METHOD


	METHOD OnKeyDown(sender AS System.Object , e AS System.Windows.Forms.KeyEventArgs) AS VOID
        
		IF bGameOver || bPaused
			RETURN
		ENDIF
		
		IF e:KeyCode == Keys.Left
			bGoLeft := TRUE
			cFacing := "left" 
			oPlayer:Image := (System.Drawing.Bitmap)oResourceManager:GetObject("left.png")
		ENDIF 
		
		IF e:KeyCode == Keys.Right
			bGoRight := TRUE
			cFacing := "right"
			oPlayer:Image := (System.Drawing.Bitmap)oResourceManager:GetObject("right.png")
		ENDIF
		
		IF e:KeyCode == Keys.Up
			bGoUp := TRUE
			cFacing := "up"
			oPlayer:Image := (System.Drawing.Bitmap)oResourceManager:GetObject("up.png")
		ENDIF
		
		IF e:KeyCode == Keys.Down
			bGoDown := TRUE
			cFacing := "down"
			oPlayer:Image := (System.Drawing.Bitmap)oResourceManager:GetObject("down.png")
		ENDIF
	END METHOD


	METHOD OnKeyUp(sender AS System.Object , e AS System.Windows.Forms.KeyEventArgs) AS VOID
		
		IF e:KeyCode == Keys.Left && !bPaused
			bGoLeft := FALSE
		ENDIF 
		
		IF e:KeyCode == Keys.Right && !bPaused
			bGoRight := FALSE
		ENDIF
		
		IF e:KeyCode == Keys.Up && !bPaused
			bGoUp := FALSE
		ENDIF
		
		IF e:KeyCode == Keys.Down && !bPaused
			bGoDown := FALSE
		ENDIF
		
		// space: shoot
		// solo se dispara cuando se suelta la barra espaciadora
		IF e:KeyCode == Keys.Space && nAmmo > 0 && !bGameOver && !bPaused
			nAmmo--
			ShootBullet(cFacing)

			IF nAmmo < 1
				DropAmmo()
			ENDIF
		ENDIF
		
		IF e:KeyCode == keys.Enter
			IF bGameOver
				RestartGame()
				RETURN
			ENDIF
			bPaused := !bPaused
		ENDIF
	
		
	END METHOD
	
	METHOD ShootBullet(tcDirection AS STRING) AS VOID
		LOCAL loShootBullet := Bullet{} AS Bullet
		loShootBullet:cDirection := tcDirection
		loShootBullet:nBulletLeft := oPlayer:Left + (oPlayer:Width/2)
		loShootBullet:nBulletTop := oPlayer:Top + (oPlayer:Height/2)
		loShootBullet:MakeBullet(SELF)
	END METHOD
	
	METHOD MakeZombies AS VOID
		LOCAL loZombie := PictureBox{} AS PictureBox
		loZombie:Image := (System.Drawing.Bitmap)oResourceManager:GetObject("zdown.png")
		loZombie:Tag := "zombie"
		loZombie:Left := oRandom:Next(0, 900)
		loZombie:Top := oRandom:Next(0, 800)
		loZombie:SizeMode := PictureBoxSizeMode.AutoSize
		oZombieList:Add(loZombie)
		Controls:Add(loZombie)
		oPlayer:BringToFront()
	END METHOD
	
	PRIVATE METHOD DropAmmo AS VOID
		LOCAL loAmmo := PictureBox{} AS PictureBox
		WITH loAmmo
			:Image := (System.Drawing.Bitmap)oResourceManager:GetObject("ammo-Image.png")
			:SizeMode := PictureBoxSizeMode.AutoSize
			:Left := oRandom:Next(10, ClientSize:Width-:Width)
			:Top := oRandom:Next(60, ClientSize:Height-:Height)
			:Tag := "ammo"
		END WITH
		Controls:Add(loAmmo)
		loAmmo:BringToFront()
		oPlayer:BringToFront()
	END METHOD
	
	
	METHOD RestartGame AS VOID
		oPlayer:Image := (System.Drawing.Bitmap)oResourceManager:GetObject("up.png")
		FOREACH loZombie AS PictureBox IN oZombieList
			Controls:Remove(loZombie)
		END FOR
		oZombieList:Clear()
		
		FOR VAR i:=1 TO 3
			MakeZombies()
		END FOR
		
		bGoUp := FALSE
		bGoDown := FALSE
		bGoLeft := FALSE
		bGoRight := FALSE
		bGameOver := FALSE
		
		nPlayerHealth := 100
		nScore := 0
		nAmmo := 10
		
		oGameTimer:Start()
		
	END METHOD


	METHOD TimerPauseTick(sender AS System.Object , e AS System.EventArgs) AS VOID
		otxtPause:Visible := !otxtPause:Visible
		otxtPause:BringToFront()
	END METHOD

END CLASS

