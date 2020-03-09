function showGameInstructions(type, window, ii)

writePTBMessage(type, 3, window)

switch type
    case 'general'
        writePTBMessage(['a light will flicker in the center of the screen' ], 5, window)
        return
    case 'static'
        writePTBMessage(['Fixate your eye on the red circle in the middle of the screen' ], 5, window)
    case 'left and right passive pursuit'
        writePTBMessage('Follow the moving circle flicker while maintaining filxation on the red circle' , 5, window)
    case 'left and right control'
        writePTBMessage('Move the circle flicker left and right to the highlighted target \n by pressing 4 and 6 on the keypad in front' , 8, window)
    case 'free movement'
        writePTBMessage('Move the circle flicker freely in any direction you desire' , 5, window)
end

if ii == 1
    writePTBMessage('A circular ring will appear in the center of the flicker with changing colors.' , 5, window)
    writePTBMessage('Remember the order of the color changes.' , 5, window)
    writePTBMessage('A multiple choice quiz will appear after each trial.' , 5, window)
    writePTBMessage('Choose the correct color order by pressing 1, 2, or 3 on the keypad' , 5, window)
    writePTBMessage('You will have 5 seconds to answer the question.' , 5, window)
    writePTBMessage('Also, there is a static red dot will be in the flicker.' , 5, window)
end
writePTBMessage('Keep eye fixated on that dot at all times. \n Otherwise, the keyboard will be disabled.' , 5, window)
writePTBMessage('Flicker will be disabled if the eye is not fixated on the red circle.', 5, window)
writePTBMessage('Experiment will begin in 3' ,1, window)
writePTBMessage('Experiment will begin in 2' , 1, window)
writePTBMessage('Experiment will begin in 1' , 1, window)
