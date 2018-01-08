function [horz_acc, vert_acc, horz_confusion, vert_confusion] = ...
    STcheckAccuracy(labels, true_labels)
    %labels and true_labels are struct arrays of the type 
    %created by APPtestImage. 
    %returns a confusion matrix for the vertical classes and
    %horizontal subclasses
    %and the overall classification accuracy
    
    horz_confusion = zeros(6);
    vert_confusion = zeros(3);
    
    for f=1:length(labels)
        horz = labels(f).horz_labels;
        vert = labels(f).vert_labels;
        true_horz = true_labels(f).horz_labels;
        true_vert = true_labels(f).vert_labels;
        
        %decode labels for simpler analysis. Concatenate '045' and '090'
        %vertical labels since that's what he does in the paper
        vert(strcmp(vert, '000')) = {'ground'};
        vert(strcmp(vert, '090')) = {'wall'};
        vert(strcmp(vert, '045')) = {'wall'};
        
        true_vert(strcmp(true_vert, '000')) = {'ground'};
        true_vert(strcmp(true_vert, '090')) = {'wall'};
        true_vert(strcmp(true_vert, '045')) = {'wall'};
        
        horz(strcmp(horz, '045')) = {'left'};
        horz(strcmp(horz, '135')) = {'right'};
        horz(strcmp(horz, '090')) = {'center'};
        
        true_horz(strcmp(true_horz, '045')) = {'left'};
        true_horz(strcmp(true_horz, '135')) = {'right'};
        true_horz(strcmp(true_horz, '090')) = {'center'};
        
         %compute confusion
        horz_conf = confusionmat(true_horz, horz, 'order', {'left', 'center', 'right', 'por', 'sol', '---'})
        vert_conf = confusionmat(true_vert, vert, 'order', {'ground', 'wall', 'sky'})
        horz_confusion = horz_confusion + horz_conf;
        vert_confusion = vert_confusion + vert_conf;
    end
    
    
    %compute accuracy
    horz_correct = sum(diag(horz_confusion));
    horz_total = sum(horz_confusion(:));
    vert_correct = sum(diag(vert_confusion));
    vert_total = sum(vert_confusion(:));
    horz_acc = horz_correct/horz_total;
    vert_acc = vert_correct/vert_total;
    
    
    