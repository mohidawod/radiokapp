import React, { useState } from 'react';
import en from '../../i18n/en.json';

type Translation = typeof en.errorAlert;

interface ErrorAlertProps {
  translation?: Translation;
  reason: string;
  suggestion: string;
  technicalDetails?: string;
}

const ErrorAlert: React.FC<ErrorAlertProps> = ({
  translation = en.errorAlert,
  reason,
  suggestion,
  technicalDetails,
}) => {
  const [showDetails, setShowDetails] = useState(false);

  const toggleDetails = () => setShowDetails((prev) => !prev);

  return (
    <div role="alert" className="error-alert">
      <p>{translation.title}</p>
      <p>{translation.reason.replace('{{reason}}', reason)}</p>
      <p>{translation.suggestion.replace('{{suggestion}}', suggestion)}</p>
      {technicalDetails && (
        <div>
          <button onClick={toggleDetails}>
            {showDetails ? translation.hideDetails : translation.showDetails}
          </button>
          {showDetails && <pre>{technicalDetails}</pre>}
        </div>
      )}
    </div>
  );
};

export default ErrorAlert;
