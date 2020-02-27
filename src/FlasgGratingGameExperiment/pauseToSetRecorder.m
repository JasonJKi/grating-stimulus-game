function answer = pauseToSetRecorder(message)
answer = questdlg(message);
if ~strcmp('Yes', answer)
    return
end