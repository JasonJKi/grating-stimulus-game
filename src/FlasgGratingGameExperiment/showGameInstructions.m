function showGameInstructions(type, window)

writePTBMessage(type, 3, window)

switch type
    case 'general'
        writePTBMessage(['a light will flicker in the center of the screen' ], 5, window)
        return
    case 'static'
        writePTBMessage(['fixate your eye on the red circle in the middle of the screen' ], 5, window)
    case 'passive pursuit'
        writePTBMessage('Follow the moving circle flicker while maintaining filxation on the red circle' , 5, window)
    case 'active control'
        writePTBMessage('Move the circle flicker left and right arrow on the keyboard in front of you' , 5, window)
end
writePTBMessage('keep eye fixated on the red circle at all times.' , 5, window)
writePTBMessage('flicker will be disabled if the eye is not fixated on the red circle.', 5, window)
